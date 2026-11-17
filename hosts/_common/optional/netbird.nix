# Netbird client — self-hosted control plane on docker-01 (nb.rx88.ws).
#
# Roles: the overlay answers "how do my devices find each other" (and later,
# optionally, "where does my internet exit"). WireGuard is NOT retired here:
# `wireguard.nix` stays as a manual break-glass path.
#
# Enrolment is a one-time, manual step per host — the setup key is a secret and
# must not be committed. Run once:
#
#   sudo netbird up --management-url https://nb.rx88.ws --setup-key <key>
#
# State (config.json / state.json, i.e. the peer identity) lives in
# /var/lib/netbird and is persisted below; once enrolled, reboots and rebuilds
# keep the same peer.
{
  pkgs,
  lib,
  config,
  ...
}:
let
  # The netbird in PATH is a wrapper around netbird-client; the wrapper has no
  # share/ tree, so expose the zsh completion shipped by the underlying package.
  netbirdCompletions = pkgs.runCommandLocal "netbird-zsh-completion" { } ''
    install -Dm644 ${pkgs.netbird}/share/zsh/site-functions/_netbird \
      $out/share/zsh/site-functions/_netbird
  '';

  client = config.services.netbird.clients.netbird;
  atHome = import ../lib/at-home.nix { inherit pkgs; };
in
{
  services.netbird = {
    enable = true;

    # Leaf node: never forward for others, but tolerate the reverse-path check
    # on the overlay's asymmetric-looking return traffic.
    useRoutingFeatures = "client";

    clients.netbird = {
      # Netbird's own default interface name is per-client ("nb-netbird");
      # pinning it keeps the firewall rule below stable and readable.
      interface = "wt0";

      # WireGuard port the client offers for direct (P2P) connections. The
      # host's own WireGuard uses an ephemeral source port, so this is free.
      port = 51820;

      # Do not auto-connect before login; `netbird up` is the enrolment step.
      # Reconnects on boot happen from the persisted state, which is the point.
      autoStart = true;
    };
  };

  # Re-establish connections on network changes (Linux defaults to off).
  # Without it, unplugging from home keeps the control plane pointed at
  # docker01's LAN address, which away is only reachable through the tunnel
  # that needs that control plane: everything stalls. Set as its own config.d
  # drop-in (merged into config.json on service start), because
  # `clients.netbird.config.X` collides with the submodule's `config` keyword.
  environment.etc."netbird/config.d/60-network-monitor.json".text = builtins.toJSON {
    NetworkMonitor = true;
  };

  # T3 Code (:3773) is reachable via the overlay interface and, for phones and
  # laptops on home Wi-Fi without NetBird, from the LAN subnet. Both paths still
  # require a T3 pairing token for any non-loopback connection.
  networking.firewall.interfaces.wt0.allowedTCPPorts = [ 3773 ];

  # `extraInputRules` is nftables-only, so with this host's iptables backend the
  # home-subnet exception has to be appended via extraCommands. Scoping by
  # source keeps the port closed on foreign networks (cafe Wi-Fi, etc.).
  networking.firewall.extraCommands = ''
    iptables -w -A nixos-fw -s 192.168.1.0/24 -p tcp --dport 3773 -j nixos-fw-accept
  '';

  # Exit-node safety net. With an exit node active, NetBird installs
  # `not fwmark 0x1bd00 lookup 7120` (default dev wt0). In 0.82 its management
  # and signal gRPC sockets are not reliably fwmarked, so they get routed into
  # the tunnel, which can only come up via signal: a deadlock that also kills
  # the host's internet. Pin the control plane to the normal routing table with
  # a rule that is evaluated before NetBird's (priority 100 < 105/110).
  #
  # Only the PUBLIC address is pinned, resolved via public DNS: Pi-hole answers
  # nb.rx88.ws with docker01's LAN IP, and pinning that would send away-from-
  # home traffic for docker01 (ssh, Traefik) out the café uplink instead of the
  # tunnel. At home the LAN route already wins over the tunnel without a rule.
  systemd.services.netbird-control-bypass = {
    description = "Keep NetBird control plane out of the exit-node tunnel";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    path = [
      pkgs.iproute2
      pkgs.dnsutils
      pkgs.gnugrep
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = 10;
    };
    script = ''
      ips=$(dig +short +time=3 +tries=1 A nb.rx88.ws @1.1.1.1 || dig +short +time=3 +tries=1 A nb.rx88.ws @9.9.9.9)
      ips=$(printf '%s\n' "$ips" | grep -E '^[0-9.]+$' | grep -vE '^(10|127|192\.168)\.' | sort -u)
      [ -n "$ips" ] || exit 1
      while ip rule del priority 100 2>/dev/null; do :; done
      for ip in $ips; do
        ip rule add priority 100 to "$ip" lookup main
      done
    '';
    preStop = ''
      while ip rule del priority 100 2>/dev/null; do :; done
    '';
  };

  # Exit node home/away, like wg-health did for wg0: off at home (the LAN is
  # local), on when away (docker01 carries everything, LAN included). NetBird
  # itself stays connected either way. Runs on every network change, and once
  # a minute as a backstop.
  systemd.services.netbird-exit-switch = {
    description = "Use the NetBird exit node only when away from home";
    after = [ "${client.service.name}.service" ];
    path = [
      client.wrapper
      pkgs.gnugrep
      pkgs.gnused
    ];
    serviceConfig.Type = "oneshot";
    script = ''
      id="Exit Node (docker01)" # the exit node's name in the NetBird dashboard

      # A network change also restarts NetBird (network monitor), so give it
      # up to 30s to reconnect instead of giving up until the next timer run.
      for _ in $(seq 15); do
        list=$(netbird networks list 2>/dev/null) && break
        sleep 2
      done

      status=$(printf '%s\n' "''${list:-}" | grep -A2 -F "ID: $id" | sed -n 's/.*Status: //p')
      [ -n "$status" ] || exit 0 # not offered to this host, or daemon down

      if ${atHome}; then
        [ "$status" = "Not Selected" ] || netbird networks deselect "$id"
      else
        [ "$status" = "Selected" ] || netbird networks select --append "$id"
      fi
    '';
  };

  systemd.timers.netbird-exit-switch = {
    wantedBy = [ "timers.target" ];
    timerConfig.OnUnitActiveSec = "60s";
    timerConfig.OnBootSec = "30s";
  };

  networking.networkmanager.dispatcherScripts = [
    {
      source = pkgs.writeShellScript "netbird-exit-switch-dispatch" ''
        ${pkgs.systemd}/bin/systemctl start --no-block netbird-exit-switch.service
      '';
    }
  ];

  # Peer identity must survive impermanence, or every boot re-enrols as a new
  # device (and the old peer lingers in the dashboard forever).
  environment.persistence."/persist".directories = [ "/var/lib/netbird" ];

  # The hardened client runs as the dedicated `netbird` user; its control
  # socket is group-owned, so the human needs membership to run `netbird`
  # commands without sudo gymnastics.
  users.users.rajx88.extraGroups = [ "netbird" ];

  # netbird itself is a system package; expose its packaged completion to the
  # human's zsh.
  home-manager.users.rajx88.home.packages = [ netbirdCompletions ];
}
