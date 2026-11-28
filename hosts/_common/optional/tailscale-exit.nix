# Away-from-home exit node — for hosts that travel (yuji).
#
# akarnae is stationary and does NOT import this: it is always on the home LAN,
# so it has no use for an exit node and no reason to probe "am I home".
#
# This replaces `netbird-exit-switch`, which did the same job for the NetBird
# overlay. Exactly one overlay may own the away-exit role — two owners would
# both install a default route and traffic would follow whichever won the race.
# See the note in netbird.nix.
{ config, pkgs, ... }:
let
  # Same helper wireguard.nix uses, so both tunnels agree on where "home" is.
  atHome = import ../lib/at-home.nix { inherit pkgs; };
  tailscale = "${config.services.tailscale.package}/bin/tailscale";
in
{
  # Off at home (the LAN is local, the exit node only adds latency), on when
  # away so docker01 carries everything, LAN included.
  #
  # `--exit-node-allow-lan-access` is what keeps 192.168.1.0/24 reachable while
  # full-tunnelling; without it the exit node swallows the accepted subnet
  # route and the NAS/Pi-hole disappear.
  systemd.services.tailscale-exit-switch = {
    description = "Use the Tailscale exit node only when away from home";
    after = [ "tailscaled.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      if ${atHome}; then
        ${tailscale} set --exit-node=
      else
        # Tolerate docker01-ts being offline: a stale exit node must not wedge
        # the switch, and the timer retries within a minute.
        ${tailscale} set --exit-node=docker01-ts --exit-node-allow-lan-access \
          || echo "tailscale exit node not applied (docker01-ts unreachable?)" >&2
      fi
    '';
  };

  systemd.timers.tailscale-exit-switch = {
    wantedBy = [ "timers.target" ];
    timerConfig.OnUnitActiveSec = "60s";
    timerConfig.OnBootSec = "30s";
  };

  networking.networkmanager.dispatcherScripts = [
    {
      source = pkgs.writeShellScript "tailscale-exit-switch-dispatch" ''
        ${pkgs.systemd}/bin/systemctl start --no-block tailscale-exit-switch.service
      '';
    }
  ];
}
