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
  systemd.services.netbird-control-bypass = {
    description = "Keep NetBird control plane out of the exit-node tunnel";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    path = [
      pkgs.iproute2
      pkgs.glibc.bin
      pkgs.gawk
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = 10;
    };
    script = ''
      ips=$(getent ahostsv4 nb.rx88.ws | awk '{print $1}' | sort -u)
      [ -n "$ips" ] || exit 1
      for ip in $ips; do
        ip rule del priority 100 to "$ip" lookup main 2>/dev/null || true
        ip rule add priority 100 to "$ip" lookup main
      done
    '';
    preStop = ''
      for ip in $(getent ahostsv4 nb.rx88.ws | awk '{print $1}' | sort -u); do
        ip rule del priority 100 to "$ip" lookup main 2>/dev/null || true
      done
    '';
  };

  # Peer identity must survive impermanence, or every boot re-enrols as a new
  # device (and the old peer lingers in the dashboard forever).
  environment.persistence."/persist".directories = [ "/var/lib/netbird" ];

  # The hardened client runs as the dedicated `netbird` user; its control
  # socket is group-owned, so the human needs membership to run `netbird`
  # commands without sudo gymnastics.
  users.users.rajx88.extraGroups = [ "netbird" ];
}
