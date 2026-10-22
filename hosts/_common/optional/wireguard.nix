{ pkgs, ... }:
let
  resolvectl = "${pkgs.systemd}/bin/resolvectl";
  systemctl = "${pkgs.systemd}/bin/systemctl";
  ping = "${pkgs.iputils}/bin/ping";
  logger = "${pkgs.util-linux}/bin/logger";
  sleep = "${pkgs.coreutils}/bin/sleep";
  date = "${pkgs.coreutils}/bin/date";
  dig = "${pkgs.dnsutils}/bin/dig";
  wg = "${pkgs.wireguard-tools}/bin/wg";
  ip = "${pkgs.iproute2}/bin/ip";
  awk = "${pkgs.gawk}/bin/awk";

  wgSwitch = pkgs.writeShellScript "wg-switch" ''
    # runs as root via pkexec — stop $1, start $2
    [ -n "$1" ] && ${systemctl} stop "$1" 2>/dev/null
    [ -n "$2" ] && ${systemctl} start "$2"
  '';

  # WiFi networks that mean "home". Everything else is "away" -> tunnel up.
  homeSsids = [ "vanbanninglan" ];

  # "Am I at home?"
  #   WiFi  -> exact match on the active connection's SSID. Deterministic, no
  #            pings, no races, and immune to "pihole is down so I look away".
  #   Wired -> a dock can be plugged in anywhere, so we can't trust the link
  #            alone; fall back to probing the LAN gateway / pihole.
  atHome = pkgs.writeShellScript "wg-at-home" ''
    set -u
    if ${pkgs.networkmanager}/bin/nmcli -t -f NAME,TYPE connection show --active 2>/dev/null \
      | ${pkgs.gnugrep}/bin/grep -qE "^(${pkgs.lib.concatStringsSep "|" homeSsids}):802-11-wireless"; then
      exit 0
    fi
    for ifc in $(${pkgs.iproute2}/bin/ip -o link show up \
      | ${pkgs.gawk}/bin/awk -F': ' '{print $2}' \
      | ${pkgs.gnugrep}/bin/grep -v -E '^(wg|lo|docker|veth|br-|virbr|tailscale|wl)'); do
      for host in 192.168.1.1 192.168.1.254; do
        ${ping} -c1 -W1 -I "$ifc" -n "$host" >/dev/null 2>&1 && exit 0
      done
      ${sleep} 0.3
    done
    exit 1
  '';

  # Resolve the endpoint from /persist. That file holds a HOSTNAME (kept current
  # by the home router's DDNS client on vpn.rx88.ws), not a hardcoded IP, so a
  # changing home IP no longer silently breaks the tunnel. Resolution goes to a
  # public resolver DIRECTLY — never via wg0, whose `~.` DNS hangs when the
  # tunnel is dead (that would turn "home IP changed" into "can't find home").
  # A bare IP in the file still works.
  resolveEndpoint = pkgs.writeShellScript "wg-endpoint-resolve" ''
    set -eu
    endpoint="$(cat /persist/secrets/wireguard/endpoint)"
    host="''${endpoint%:*}"
    port="''${endpoint##*:}"
    case "$host" in *[!0-9.]*) ;; *) echo "$endpoint"; exit 0 ;; esac
    for ns in 9.9.9.9 1.1.1.1; do
      ip="$(${dig} +short +time=3 +tries=1 A "$host" "@$ns" 2>/dev/null \
        | ${pkgs.gnugrep}/bin/grep -E '^[0-9]+\.' | head -1 || true)"
      [ -n "$ip" ] && { echo "$ip:$port"; exit 0; }
    done
    echo "wg-endpoint-resolve: cannot resolve $host" >&2
    exit 1
  '';

  # Runs every minute and on NM link events. Keeps the tunnel up when away and
  # down when home — and if it cannot connect, FALLS BACK to a direct
  # connection and notifies, instead of silently blackholing everything.
  wgHealth = pkgs.writeShellScript "wg-health" ''
    set -u
    state=/run/wg-health.state
    netfile=/run/wg-health.net

    # Don't fight an in-flight nixos activation: switch-to-configuration
    # stops/starts wg-quick-wg0 itself (the unit may have changed), and a
    # racing stop from here makes the activation fail with exit 4
    # ("Failed to start wg-quick-wg0.service").
    if ${pkgs.procps}/bin/pgrep -f switch-to-configuration >/dev/null 2>&1; then
      exit 0
    fi

    note() {
      ${logger} -t wg-health "WireGuard DOWN — using direct connection: $1"
      ${pkgs.util-linux}/bin/wall "WireGuard DOWN — using direct connection: $1" 2>/dev/null || true
      for bus in /run/user/*/bus; do
        [ -S "$bus" ] || continue
        DBUS_SESSION_BUS_ADDRESS="unix:path=$bus" \
          ${pkgs.libnotify}/bin/notify-send -u critical -a WireGuard "WireGuard DOWN — using direct connection" "$1" 2>/dev/null && break
      done
    }

    exec 9>/run/wg-health.lock
    ${pkgs.util-linux}/bin/flock -w 30 9 || exit 0
    prev="$(cat "$state" 2>/dev/null || echo unknown)"
    sig="$(${ip} route show default | head -1)"

    # No default route yet (first seconds after boot, or mid link-change)?
    # Nothing to tunnel over, and "home" is unknowable — stay silent instead
    # of blackhole-probing and broadcasting a false DOWN. The NM dispatcher
    # wakes us on up/dhcp4-change when a link appears.
    if [ -z "$sig" ]; then
      exit 0
    fi

    if ${atHome}; then
      ${systemctl} is-active --quiet wg-quick-wg0 && ${systemctl} stop --quiet wg-quick-wg0
      echo home > "$state"; echo "$sig" > "$netfile"
      exit 0
    fi

    # Don't re-blackhole the same broken network every minute — but still retry
    # every 10 min in case home came back (else the tunnel never returns while
    # you sit on one network).
    if [ "$prev" = failed ] && [ "$(cat "$netfile" 2>/dev/null)" = "$sig" ]; then
      last=$(${date} -r "$netfile" +%s 2>/dev/null || echo 0)
      t_now=$(${date} +%s)
      [ $((t_now - last)) -lt 600 ] && exit 0
    fi

    ${systemctl} start --quiet wg-quick-wg0 || true
    ${sleep} 2

    # An idle wg0 sends nothing — the handshake is only triggered by the first
    # outbound traffic, so a handshake-only check on a fresh tunnel always
    # fails. Generate the traffic ourselves and judge on the result: either
    # reply proves the tunnel carries data (server IP = tunnel itself,
    # Pi-hole = full path incl. forwarding).
    if ${ping} -c2 -W2 -I wg0 -n 10.69.43.1 >/dev/null 2>&1 \
       || ${ping} -c2 -W2 -I wg0 -n 192.168.1.254 >/dev/null 2>&1; then
      [ "$prev" = ok ] || ${logger} -t wg-health "tunnel healthy"
      echo ok > "$state"; echo "$sig" > "$netfile"
    else
      ${systemctl} stop --quiet wg-quick-wg0   # release the full-tunnel route
      [ "$prev" = failed ] || note "home unreachable — no route through the tunnel"
      echo failed > "$state"; echo "$sig" > "$netfile"
    fi
  '';
in
{
  # Stable path for wg-switch so polkit policy can reference it
  environment.etc."wg-switch" = {
    source = wgSwitch;
    mode = "0755";
  };
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
  # ALL DNS through the tunnel. Public resolvers back pihole up so a dead
  # pihole (or a link that hands out no DNS) never hangs resolution.
  # Order: pihole → Quad9 → Cloudflare.
  services.resolved.settings.Resolve = {
    DNS = "192.168.1.254 9.9.9.9 1.1.1.1";
    Domains = "~lan";
    ResolveUnicastSingleLabel = true;
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

  # Wake the health check on link events (non-blocking — NM must not wait on
  # the pings/sleeps inside wg-health).
  networking.networkmanager.dispatcherScripts = [
    {
      type = "basic";
      source = pkgs.writeShellScript "wg-dispatch" ''
        case "$2" in up|dhcp4-change|connectivity-change|down) ;; *) exit 0 ;; esac
        case "$1"  in wg0|lo|docker*|veth*|br-*|virbr*|tailscale*|"") exit 0 ;; esac
        ${systemctl} start --no-block wg-health.service
      '';
    }
  ];

  networking.wg-quick.interfaces = {
    # Full-tunnel for IPv4 and DNS through home.
    # IPv6 is intentionally NOT tunneled (no ::/0): the server's wg0 has no
    # IPv6 address or NAT66, so routing ::/0 into it blackholed all IPv6 and
    # made dual-stack sites/apps hang. IPv6 now uses the native uplink.
    # At home wg-health keeps this DOWN — pihole + LAN handle everything
    # natively.
    wg0 = {
      address = [ "10.69.43.2/24" ];
      # The endpoint is injected in postUp from /persist, so wg-quick can't
      # derive the path MTU itself (it falls back to the physical default
      # route and varies by uplink: 1420 on ethernet, 1220 on some hotspots).
      mtu = 1420;
      privateKeyFile = "/persist/secrets/wireguard/private.key";
      autostart = false;

      # /persist/secrets/wireguard/endpoint holds "vpn.rx88.ws:51820" — a
      # DDNS hostname, NOT a hardcoded IP, so a changing home IP is picked up
      # automatically. (DNS-only record: a proxied record can't carry WG.)
      # Migrate once on the machine:
      #   echo "vpn.rx88.ws:51820" | sudo tee /persist/secrets/wireguard/endpoint
      postUp = ''
        ${wg} set wg0 \
          peer 7QagNiSoCbm5Yjr6oX9I86yJJOCQF+2LR1WQAQ/wozs= \
          endpoint "$(${resolveEndpoint})"
      '';

      peers = [
        {
          publicKey = "7QagNiSoCbm5Yjr6oX9I86yJJOCQF+2LR1WQAQ/wozs=";
          allowedIPs = [ "0.0.0.0/0" ];
          persistentKeepalive = 25;
        }
      ];
    };
  };

  # Drive resolved AFTER wg-quick is fully up — avoids a race we hit with PostUp.
  # ExecStopPost reverts so leaving the tunnel doesn't leak stale state.
  #
  # Point the tunnel straight at the Pi-hole VIP (192.168.1.254), reachable
  # through the tunnel, rather than at the server's CoreDNS container
  # (10.69.43.1). The VIP is held by whichever Pi-hole node is alive
  # (keepalived/VRRP), so this single address survives either node failing.
  # wg0's `~.` route sends EVERY name (including .lan) to it, so
  # gravity/filtering applies and there is no CoreDNS middleman to keep alive
  # across restarts. Quad9 then Cloudflare are secondaries: if the VIP is
  # unreachable through the tunnel, DNS falls back instead of hanging.
  systemd.services.wg-quick-wg0.serviceConfig = {
    ExecStartPost = [
      "${resolvectl} dns    wg0 192.168.1.254 9.9.9.9 1.1.1.1"
      "${resolvectl} domain wg0 '~.'"
    ];
    ExecStopPost = "-${resolvectl} revert wg0";
  };

  # Health check / fallback / notify (see wgHealth above): every minute,
  # plus on boot and on NM link events.
  systemd.services.wg-health = {
    description = "WireGuard tunnel health check with fallback";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${wgHealth}";
      TimeoutStartSec = 120;
    };
  };

  systemd.timers.wg-health = {
    description = "Periodic WireGuard tunnel health check";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "45s";
      OnUnitActiveSec = "60s";
      AccuracySec = "10s";
    };
  };
}
