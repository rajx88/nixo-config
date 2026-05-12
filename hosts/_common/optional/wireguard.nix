{ pkgs, ... }: let
  resolvectl = "${pkgs.systemd}/bin/resolvectl";
  systemctl  = "${pkgs.systemd}/bin/systemctl";
  ping       = "${pkgs.iputils}/bin/ping";

  # Pure TCP probe to pihole on the local link. No DNS, no public name.
  # 192.168.1.0/24 is not in wg0's allowedIPs, so the packet always takes
  # the local link — success means we're physically on the home LAN.
  homeProbe = pkgs.writeShellScript "wg-home-away-dispatcher" ''
    set -u
    export PATH=/run/current-system/sw/bin:/run/wrappers/bin:$PATH
    iface="$1"
    status="$2"

    # Only react to relevant NM events on real physical interfaces.
    case "$status" in up|dhcp4-change|connectivity-change|down) ;; *) exit 0 ;; esac
    case "$iface"  in
      wg0|wg-full|lo|docker*|veth*|br-*|virbr*|tailscale*) exit 0 ;;
      "")                                                  exit 0 ;;
    esac

    at_home() {
      for _ in 1 2 3 4 5; do
        ${ping} -c1 -W1 -n 192.168.1.100 >/dev/null 2>&1 && return 0
        sleep 0.5
      done
      return 1
    }

    enter_home() {
      ${systemctl} stop --quiet wg-quick-wg0 || true
      logger -t wg-home-away "home ($iface $status) — wg0 stopped"
    }

    enter_away() {
      ${systemctl} start --quiet wg-quick-wg0 || true
      logger -t wg-home-away "away ($iface $status) — wg0 started"
    }

    if at_home; then enter_home; else enter_away; fi
  '';
in {
  services.resolved.enable = true;
  networking.networkmanager.dns = "systemd-resolved";

  # Global routing domain: every *.lan query goes to pihole regardless of
  # per-link DNS or IPv6 RA RDNSS leaks. When wg0 is up, its more-specific
  # per-link `~lan` overrides this and routes via CoreDNS through the tunnel.
  services.resolved.settings.Resolve = {
    DNS = "192.168.1.100";
    Domains = "~lan";
  };

  # Re-enable IPv6 globally. The dispatcher pins .lan→pihole on the active
  # home link, so IPv6 RA RDNSS leaks no longer break .lan resolution.
  networking.networkmanager.settings = {
    connection = {
      "ipv6.method" = "auto";
    };
  };

  networking.networkmanager.dispatcherScripts = [{
    type   = "basic";
    source = homeProbe;
  }];

  networking.wg-quick.interfaces = {
    # Away-from-home split-tunnel. At home, leave this DOWN — pihole + LAN
    # handle *.lan natively; the tunnel would only hijack DNS through a
    # broken hairpin path.
    wg0 = {
      address = [ "10.69.43.2/24" ];
      privateKeyFile = "/persist/secrets/wireguard/private.key";
      autostart = false;

      peers = [{
        publicKey = "7QagNiSoCbm5Yjr6oX9I86yJJOCQF+2LR1WQAQ/wozs=";
        endpoint = "vpn.rx88.ws:51820";
        allowedIPs = [ "10.69.43.0/24" ];
        persistentKeepalive = 25;
      }];
    };

    # Full-tunnel "DEFCON" mode: ALL traffic and ALL DNS through home.
    wg-full = {
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
      "${resolvectl} domain wg0 '~lan'"
    ];
    ExecStopPost = "-${resolvectl} revert wg0";
  };

  systemd.services.wg-quick-wg-full.serviceConfig = {
    ExecStartPost = [
      "${resolvectl} dns    wg-full 10.69.43.1"
      "${resolvectl} domain wg-full '~.'"
    ];
    ExecStopPost = "-${resolvectl} revert wg-full";
  };
}
