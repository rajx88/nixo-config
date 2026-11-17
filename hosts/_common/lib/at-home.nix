# "Am I at home?" — exit 0 = home, 1 = away. Shared by the WireGuard
# break-glass tunnel (wireguard.nix) and the NetBird exit-node switch
# (netbird.nix) so both agree on where "home" is.
#
# Not a NixOS module: `import ../lib/at-home.nix { inherit pkgs; }`.
#
#   WiFi  -> exact match on the active connection's SSID. Deterministic, no
#            pings, no races, and immune to "pihole is down so I look away".
#   Wired -> a dock can be plugged in anywhere, so we can't trust the link
#            alone; fall back to probing the LAN gateway / pihole. `-I` binds
#            the probe to the physical link, so an active tunnel can't answer.
{ pkgs }:
let
  # WiFi networks that mean "home". Everything else is "away".
  homeSsids = [ "home-ssid" ];
in
pkgs.writeShellScript "at-home" ''
  set -u
  if ${pkgs.networkmanager}/bin/nmcli -t -f NAME,TYPE connection show --active 2>/dev/null \
    | ${pkgs.gnugrep}/bin/grep -qE "^(${pkgs.lib.concatStringsSep "|" homeSsids}):802-11-wireless"; then
    exit 0
  fi
  for ifc in $(${pkgs.iproute2}/bin/ip -o link show up \
    | ${pkgs.gawk}/bin/awk -F': ' '{print $2}' \
    | ${pkgs.gnugrep}/bin/grep -v -E '^(wg|wt|lo|docker|veth|br-|virbr|tailscale|wl)'); do
    for host in 192.168.1.1 192.168.1.254; do
      ${pkgs.iputils}/bin/ping -c1 -W1 -I "$ifc" -n "$host" >/dev/null 2>&1 && exit 0
    done
    ${pkgs.coreutils}/bin/sleep 0.3
  done
  exit 1
''
