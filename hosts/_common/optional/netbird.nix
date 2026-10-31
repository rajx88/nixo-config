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

  # T3 Code (:3773) is reachable ONLY via the overlay interface — LAN clients
  # cannot reach it, which is the inside/outside boundary we designed for.
  # Loopback is always allowed, so the desktop app's local attach keeps working.
  networking.firewall.interfaces.wt0.allowedTCPPorts = [ 3773 ];

  # Peer identity must survive impermanence, or every boot re-enrols as a new
  # device (and the old peer lingers in the dashboard forever).
  environment.persistence."/persist".directories = [ "/var/lib/netbird" ];

  # The hardened client runs as the dedicated `netbird` user; its control
  # socket is group-owned, so the human needs membership to run `netbird`
  # commands without sudo gymnastics.
  users.users.rajx88.extraGroups = [ "netbird" ];
}
