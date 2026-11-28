# "Am I at home?" — exit 0 = home, 1 = away. Used by the Tailscale exit-node
# switch (tailscale-exit.nix) so it agrees with the rest of the network about
# where "home" is. The WireGuard tunnel that used to share this helper was
# retired on 2026-11-28 (see the STATUS header in optional/wireguard.nix).
#
# Not a NixOS module: `import ../lib/at-home.nix { inherit pkgs; }`.
#
#   WiFi  -> exact match on the active connection's SSID. Deterministic, no
#            pings, no races, and immune to "pihole is down so I look away".
#            The SSID itself is NOT in this repo — see `ssidFile` below.
#   Wired -> a dock can be plugged in anywhere, so we can't trust the link
#            alone; fall back to probing the LAN gateway / pihole. `-I` binds
#            the probe to the physical link, so an active tunnel can't answer.
{ pkgs }:
let
  lib = pkgs.lib;

  # The home SSID is deliberately read from outside the repo. It is the only
  # identifying string in this configuration, and this repo is public: an SSID
  # carrying a surname links the GitHub account to a physical address. Keeping
  # it in git (even in history) defeated that, so it now lives in a local file
  # and the repo only knows about the path.
  #
  # Create it once per host; it lives on /persist, so it survives the
  # impermanent root:
  #
  #   sudo install -d -m 700 /persist/secrets/network
  #   echo "<your-ssid>" | sudo tee /persist/secrets/network/home-ssid
  #   sudo chmod 600 /persist/secrets/network/home-ssid
  #
  # A string path (not a Nix path literal) keeps flake evaluation happy: the
  # file is copied into the store at build time. If it is missing the list is
  # empty and detection falls through to the LAN probe below, which is exactly
  # the path docked ethernet already takes — so a host without the file still
  # works, just less decisively.
  ssidFile = "/persist/secrets/network/home-ssid";
  homeSsids = lib.optional (builtins.pathExists ssidFile) (
    lib.removeSuffix "\n" (builtins.readFile ssidFile)
  );
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
