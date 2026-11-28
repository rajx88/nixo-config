# Tailscale — a second, out-of-band remote-access path alongside NetBird.
#
# Why a second overlay: the self-hosted NetBird control plane on docker-01
# (nb.rx88.ws) lives *inside* this lab's failure domain, so the path you would
# use to repair a wedged docker01 is the path that a wedged docker01 takes away
# with it. Tailscale's coordination server belongs to someone else, which is
# exactly what makes it useful when the lab is not. NetBird is retired from
# this host (see the STATUS header in netbird.nix); `wireguard.nix` remains the
# manual break-glass path.
#
# Roles are split, so keep this module client-only:
#
#   akarnae, yuji — leaf clients (useRoutingFeatures = "client")
#   docker01-ts   — exit node + subnet router for 192.168.1.0/24, tagged so its
#                   key never expires (tagged devices get expiry disabled at
#                   authentication; the console toggle is not durable across a
#                   re-auth, the tag is)
#
# This file is the stationary half: no exit-node selection, no "am I home"
# probing. Hosts that travel import `tailscale-exit.nix` on top of this one.
#
# Enrolment is a one-time manual step per host:
#
#   sudo tailscale up --accept-dns=false --hostname=<host> --operator=rajx88
#
# `--accept-dns=false` at enrolment is the conservative default: MagicDNS takes
# over the resolver, and it should be switched on per device (`tailscale set
# --accept-dns=true`) only after the split-DNS domain is confirmed to sit
# outside rx88.ws. Pointing tailnet DNS at Pi-hole for that name would
# resurrect the control-plane deadlock the retired `netbird-control-bypass`
# existed to prevent.
{ ... }:
{
  services.tailscale = {
    enable = true;

    # Leaf node: never forward for others. `client` also loosens reverse-path
    # filtering, which keeps traffic from an accepted subnet route or exit node
    # from being dropped as spoofed.
    useRoutingFeatures = "client";
  };

  # T3 reachable over the overlay.
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 3773 ];

  # Phones and laptops on home Wi-Fi *without* the overlay still need T3 over
  # the LAN. `extraInputRules` is nftables-only, so with this host's iptables
  # backend the home-subnet exception is appended via extraCommands. Scoping by
  # source keeps the port closed on foreign networks (cafe Wi-Fi, etc.).
  networking.firewall.extraCommands = ''
    iptables -w -A nixos-fw -s 192.168.1.0/24 -p tcp --dport 3773 -j nixos-fw-accept
  '';

  # Peer identity must survive impermanence, or every boot enrols as a brand
  # new device and the old peer lingers in the admin console forever.
  environment.persistence."/persist".directories = [ "/var/lib/tailscale" ];
}
