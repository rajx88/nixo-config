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
        for _ in 1 2 3; do
          ${ping} -c1 -W1 -I "$ifc" -n 192.168.1.100 >/dev/null 2>&1 && return 0
          ${sleep} 0.3
        done
      done
      return 1
    }

    enter_home() {
      ${systemctl} stop --quiet wg-quick-wg0 || true
      ${logger} -t wg-home-away "home ($iface $status) — wg0 stopped"
    }

    enter_away() {
      # Don't start if already running
      ${systemctl} is-active --quiet wg-quick-wg0 && return 0
      ${systemctl} start --quiet wg-quick-wg0 || true
      ${logger} -t wg-home-away "away ($iface $status) — wg0 started"
    }

    if at_home; then enter_home; else enter_away; fi
  '';
in {
  # Stable path for wg-switch so polkit policy can reference it
  environment.etc."wg-switch" = { source = wgSwitch; mode = "0755"; };
  services.resolved.enable = true;
  networking.networkmanager.dns = "systemd-resolved";

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
    # Full-tunnel: ALL traffic and ALL DNS through home.
    # At home the dispatcher keeps this DOWN — pihole + LAN handle
    # everything natively.
    wg0 = {
      address = [ "10.69.43.2/24" ];
      privateKeyFile = "/persist/secrets/wireguard/private.key";
      autostart = false;

      peers = [{
        publicKey = "7QagNiSoCbm5Yjr6oX9I86yJJOCQF+2LR1WQAQ/wozs=";
        endpoint = "vpn.rx88.ws:51820";
        allowedIPs = [ "0.0.0.0/0" "::/0" ];
        persistentKeepalive = 25;
      }];
    };
  };

  # Drive resolved AFTER wg-quick is fully up — avoids a race we hit with PostUp.
  # ExecStopPost reverts so leaving the tunnel doesn't leak stale state.
  systemd.services.wg-quick-wg0.serviceConfig = {
    ExecStartPost = [
      "${resolvectl} dns    wg0 10.69.43.1"
      "${resolvectl} domain wg0 '~.'"
    ];
    ExecStopPost = "-${resolvectl} revert wg0";
  };
}
