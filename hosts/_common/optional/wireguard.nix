{ pkgs, ... }: let
  resolvectl = "${pkgs.systemd}/bin/resolvectl";
  systemctl  = "${pkgs.systemd}/bin/systemctl";
  dig        = "${pkgs.bind.dnsutils}/bin/dig";

  # Home-detect: query pihole directly with dig (bypasses systemd-resolved,
  # so per-link DNS / IPv6 / cache races can't interfere). 192.168.1.0/24 is
  # not in wg0's allowedIPs, so the packet always takes the local link — a
  # successful query proves we're physically on the home LAN.
  homeProbe = pkgs.writeShellScript "wg-home-away-dispatcher" ''
    set -u
    export PATH=/run/current-system/sw/bin:/run/wrappers/bin:$PATH
    iface="$1"; status="$2"

    case "$status" in
      up|dhcp4-change|connectivity-change) ;;
      down) ;;
      *) exit 0 ;;
    esac

    # Don't trigger on wg interfaces themselves.
    case "$iface" in wg0|wg-full|lo) exit 0 ;; esac

    # Ask pihole directly for vpn.rx88.ws. This bypasses systemd-resolved
    # entirely, so per-link DNS / IPv6 / cache races can't interfere.
    # The packet to 192.168.1.100 always takes the local link (this subnet
    # is not in wg0's allowedIPs), so a successful query = we're on home LAN.
    # Ask pihole directly for vpn.rx88.ws. dig +short writes timeout errors
    # to stdout too, so grep down to IPv4-shaped strings only.
    ip=""
    for _ in 1 2 3 4 5 6 7 8; do
      ip=$(${dig} @192.168.1.100 +time=1 +tries=1 +short vpn.rx88.ws 2>/dev/null \
            | grep -Eo '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' | head -1)
      [ -n "$ip" ] && break
      sleep 0.5
    done

    if [ -n "$ip" ]; then
      # pihole answered → we're on home LAN.
      if ${systemctl} is-active --quiet wg-quick-wg0; then
        ${systemctl} stop wg-quick-wg0
        logger -t wg-home-away "home ($iface $status, pihole=$ip) — stopped wg0"
      fi
    else
      # pihole unreachable → we're away.
      if ! ${systemctl} is-active --quiet wg-quick-wg0; then
        ${systemctl} start wg-quick-wg0
        logger -t wg-home-away "away ($iface $status, pihole unreachable) — started wg0"
      fi
    fi
  '';
in {
  services.resolved.enable = true;
  networking.networkmanager.dns = "systemd-resolved";

  # No IPv6 yet (no pihole on IPv6, RA RDNSS keeps leaking ISP DNS into
  # resolved). Globally disable IPv6 on all NM connections; revisit when we
  # deploy a v6 DNS backend.
  networking.networkmanager.settings = {
    connection = {
      "ipv6.method" = "disabled";
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
