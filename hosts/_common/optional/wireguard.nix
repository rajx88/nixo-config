{ pkgs, ... }: let
  resolvectl = "${pkgs.systemd}/bin/resolvectl";
  systemctl  = "${pkgs.systemd}/bin/systemctl";
  ping       = "${pkgs.iputils}/bin/ping";
  logger     = "${pkgs.util-linux}/bin/logger";
  sleep      = "${pkgs.coreutils}/bin/sleep";

  wgSwitch = pkgs.writeShellScript "wg-switch" ''
    # runs as root via pkexec — stop $1, start $2
    [ -n "$1" ] && ${systemctl} stop "$1" 2>/dev/null
    [ -n "$2" ] && ${systemctl} start "$2"
  '';

  # Probe pihole on ALL up physical interfaces to detect home LAN.
  # We exclude wg0/virtual interfaces so the probe never goes through the
  # tunnel (which would falsely confirm "home"). Probing all physical NICs
  # avoids the race where WiFi triggers an event before it can route, even
  # though ethernet is already proving we're home.
  homeProbe = pkgs.writeShellScript "wg-home-away-dispatcher" ''
    set -u
    iface="$1"
    status="$2"

    # Only react to relevant NM events on real physical interfaces.
    case "$status" in up|dhcp4-change|connectivity-change|down) ;; *) exit 0 ;; esac
    case "$iface"  in
      wg0|lo|docker*|veth*|br-*|virbr*|tailscale*) exit 0 ;;
      "")                                           exit 0 ;;
    esac

    # Serialize: avoid two dispatcher instances racing each other.
    exec 9>/run/wg-home-away.lock
    ${pkgs.util-linux}/bin/flock -w 10 9 || exit 0

    at_home() {
      # Probe pihole on ALL up physical interfaces, not just the trigger.
      # Prevents race where WiFi event fires before WiFi can route, even
      # though ethernet is already connected and proving we're home.
      # wg0/lo/virtual interfaces are excluded so we never probe through the tunnel.
      for ifc in $(${pkgs.iproute2}/bin/ip -o link show up | ${pkgs.gawk}/bin/awk -F': ' '{print $2}' | ${pkgs.gnugrep}/bin/grep -v -E '^(wg|lo|docker|veth|br-|virbr|tailscale)'); do
        # Probe the LAN gateway as well as pihole. pihole lives on the same
        # host as the WireGuard server, so if that host is down/rebooting we
        # would otherwise misdetect "away", raise a full tunnel to a dead
        # endpoint, and blackhole ALL traffic while sitting at home.
        for host in 192.168.1.1 192.168.1.100; do
          ${ping} -c1 -W1 -I "$ifc" -n "$host" >/dev/null 2>&1 && return 0
        done
        ${sleep} 0.3
      done
      return 1
    }

    enter_home() {
      if ${systemctl} stop --quiet wg-quick-wg0; then
        ${logger} -t wg-home-away "home ($iface $status) — wg0 stopped"
      else
        ${logger} -t wg-home-away -p warning "home ($iface $status) — failed to stop wg0"
      fi
    }

    enter_away() {
      # Don't start if already running
      ${systemctl} is-active --quiet wg-quick-wg0 && return 0
      if ${systemctl} start --quiet wg-quick-wg0; then
        ${logger} -t wg-home-away "away ($iface $status) — wg0 started"
      else
        ${logger} -t wg-home-away -p warning "away ($iface $status) — FAILED to start wg0"
      fi
    }

    if at_home; then enter_home; else enter_away; fi
  '';
in {
  # Stable path for wg-switch so polkit policy can reference it
  environment.etc."wg-switch" = { source = wgSwitch; mode = "0755"; };
  services.resolved.enable = true;
  networking.networkmanager.dns = "systemd-resolved";

  # NM has native "wireguard" device-type support and will otherwise claim
  # wg0 the moment wg-quick creates it (no matching NM connection profile
  # for it), silently stripping the address + full-tunnel policy routes
  # wg-quick just installed. This raced unnoticed for months because "away"
  # sessions were rare/brief — confirmed via nmcli showing wg0 state
  # "disconnected" with a fully empty policy table 51820 while wg-quick
  # itself reported success.
  networking.networkmanager.unmanaged = [ "interface-name:wg0" ];

  # Global routing domain: every *.lan query goes to pihole regardless of
  # per-link DNS. When wg0 is up, its per-link `~.` overrides and routes
  # ALL DNS through the tunnel's CoreDNS.
  services.resolved.settings.Resolve = {
    DNS = "192.168.1.100";
    Domains = "~lan";
  };

  # IPv6 enabled. With dhcpcd gone (useDHCP=false), NM is sole DHCP client
  # and gets pihole DNS from DHCPv4. RA RDNSS may add extra IPv6 DNS but
  # pihole stays on per-link, and Global ~lan routing covers .lan regardless.
  networking.networkmanager.settings = {
    connection = {
      "ipv6.method" = "auto";
    };
    # Prefer ethernet over WiFi when both are connected.
    # Lower metric = higher priority default route.
    # Prevents systemd-resolved from sending DNS queries over both interfaces
    # simultaneously, which caused Pi-hole rate-limit storms (.107 + .110).
    "connection-ethernet" = {
      "ipv4.route-metric" = 10;
      "ipv6.route-metric" = 10;
    };
    "connection-wifi" = {
      "ipv4.route-metric" = 100;
      "ipv6.route-metric" = 100;
    };
  };

  networking.networkmanager.dispatcherScripts = [{
    type   = "basic";
    source = homeProbe;
  }];

  networking.wg-quick.interfaces = {
    # Full-tunnel for IPv4 and DNS through home.
    # IPv6 is intentionally NOT tunneled (no ::/0): the server's wg0 has no
    # IPv6 address or NAT66, so routing ::/0 into it blackholed all IPv6 and
    # made dual-stack sites/apps hang. IPv6 now uses the native uplink.
    # At home the dispatcher keeps this DOWN — pihole + LAN handle
    # everything natively.
    wg0 = {
      address = [ "10.69.43.2/24" ];
      # The endpoint is injected in postUp from /persist, so wg-quick can't
      # derive the path MTU itself (it falls back to the physical default
      # route and varies by uplink: 1420 on ethernet, 1220 on some hotspots).
      mtu = 1420;
      privateKeyFile = "/persist/secrets/wireguard/private.key";
      autostart = false;

      # Endpoint is not committed to the repo — read from /persist at runtime
      # so the home IP is never in git. Create once on the machine:
      #   echo "YOUR.HOME.IP:51820" > /persist/secrets/wireguard/endpoint
      #   chmod 600 /persist/secrets/wireguard/endpoint
      postUp = ''
        ${pkgs.wireguard-tools}/bin/wg set wg0 \
          peer 7QagNiSoCbm5Yjr6oX9I86yJJOCQF+2LR1WQAQ/wozs= \
          endpoint "$(cat /persist/secrets/wireguard/endpoint)"
      '';

      peers = [{
        publicKey = "7QagNiSoCbm5Yjr6oX9I86yJJOCQF+2LR1WQAQ/wozs=";
        allowedIPs = [ "0.0.0.0/0" ];
        persistentKeepalive = 25;
      }];
    };
  };

  # Drive resolved AFTER wg-quick is fully up — avoids a race we hit with PostUp.
  # ExecStopPost reverts so leaving the tunnel doesn't leak stale state.
  #
  # Point the tunnel straight at pihole (192.168.1.100), reachable through the
  # tunnel, rather than at the server's CoreDNS container (10.69.43.1). wg0's
  # `~.` route sends EVERY name (including .lan) to pihole, so gravity/filtering
  # applies and there is no CoreDNS middleman to keep alive across restarts.
  systemd.services.wg-quick-wg0.serviceConfig = {
    ExecStartPost = [
      "${resolvectl} dns    wg0 192.168.1.100"
      "${resolvectl} domain wg0 '~.'"
    ];
    ExecStopPost = "-${resolvectl} revert wg0";
  };
}
