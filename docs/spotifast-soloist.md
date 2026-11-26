# Spotifast Soloist and the NixOS firewall

## Overview

Spotifast's **Soloist** mode runs Spotify's Soloist engine as a Spotify Connect receiver. It is
downloaded by Spotifast and started as a child process; nothing in this repo configures it beyond
installing `spotifast` itself (`home/rajx88/features/desktop/optional/spotifast.nix`).

The first pairing is the only step that needs **local network discovery**: mDNS on UDP 5353 plus
Soloist's local playback endpoint on a TCP port. After that the receiver signs in, restores its own
session on every launch, and only makes outbound connections to Spotify.

`akarnae`'s NixOS firewall is enabled and default-deny inbound. The only port this repo opens is
TCP 3773 on `wt0` (`hosts/_common/optional/netbird.nix`). There is no rule for 5353 or for
Soloist's endpoint, so until it has been paired the Spotify app cannot see the device.

## Symptom

The device never appears in the Spotify device picker, so setup stays on "Connect in Spotify" /
"waiting". No crash, and nothing in `spotifast.log` beyond normal startup.

## Confirm it

Soloist's own log says it is running but has never logged in:

```bash
cat ~/.local/state/spotifast/soloist/accounts/*/soloist-output.log
# ready, device_name=Spotifast Soloist (xxxxxxxx) device_id=...
# waiting for login — connect to "Spotifast Soloist (xxxxxxxx)" from your Spotify app
```

`~/.local/state/spotifast/session.json` still has `"soloist_onboarding":"setup"`.

Soloist's sockets, and the port that matters:

```bash
ss -tlnp | grep soloist
# 127.0.0.1:43939  local WebSocket/control API — never expose this
# 0.0.0.0:<port>   local playback SDK  — the one the Spotify app connects to
```

Proof that the firewall is the wall: a test listener on the LAN address answers locally but not
from another host.

```bash
python3 -m http.server 45678 --bind 0.0.0.0 &
curl -m 3 -o /dev/null -w '%{http_code}\n' http://127.0.0.1:45678/   # 200
ssh aether@docker01 "curl -m 4 -o /dev/null -w '%{http_code}\n' http://192.168.1.108:45678/"
# 000 — blocked by default-deny before it reaches the service
```

## What the pairing needs

| Traffic | Direction | Why |
| --- | --- | --- |
| UDP 5353 | inbound, LAN | mDNS `_spotify-connect._tcp` discovery |
| TCP `<soloist port>` | inbound, LAN | Soloist's local playback SDK endpoint |
| TCP 43939 | loopback only | Soloist control API — do **not** open |

No router port-forward is involved, and Spotify's docs warn against exposing the control socket.
`avahi-daemon` is not needed: Soloist runs its own mDNS responder.

## Fix: pair once, then close again

The rules added by `nixos-firewall-tool` are runtime-only. They are not written to the Nix store or
the flake, and a reboot or `nixos-firewall-tool reset` removes them.

```bash
# 1. Current Soloist endpoint (it is OS-assigned and can change per launch)
ss -tlnp | grep soloist
port=$(ss -tlnHp | awk '$4 ~ /^0\.0\.0\.0:/ && /soloist/ {n=split($4,a,":"); print a[n]; exit}')

# 2. Open only what first pairing needs
sudo nixos-firewall-tool open udp 5353
sudo nixos-firewall-tool open tcp "$port"

# 3. On a phone on the same Wi-Fi (VPN off), start a song in Spotify, open the
#    device picker and choose "Spotifast Soloist (xxxxxxxx)". The desktop app on
#    this machine works too. Spotifast flips to verified / "Start listening".

# 4. Restore default-deny
sudo nixos-firewall-tool reset
```

If Spotifast is restarted before pairing succeeds, re-read the port: it changes.

## Optional: keep mDNS discovery permanently

Only if other local-discovery features (Cast, printers, seeing LAN speakers from Spotify) are also
wanted. This does **not** open Soloist's TCP endpoint:

```nix
# hosts/akarnae/default.nix
networking.firewall.interfaces.enp0s31f6.allowedUDPPorts = [ 5353 ];
```

Deliberately not included:

- **Pinning the TCP port** — Soloist picks a free port at each start, so a static rule goes stale.
- **`trustedInterfaces = [ "enp0s31f6" ]`** — would disable the firewall on that NIC everywhere,
  including untrusted networks the laptop is plugged into.

## After pairing

- Soloist keeps its own saved session and is restored on every Spotifast launch.
- It reaches Spotify outbound; no open ports are required, including over reboots and rebuilds.
- The 90-day build updates keep the stored session, so updating does not re-pair.
- Spotify shows it in the account's device list, same as any other signed-in Connect receiver.

Re-pair only if Spotify signs Soloist out or drops it from the device list for good (revoked key,
account change). Spotifast then asks to connect again, and the temporary open/close above is needed
once more.

## Notes

- The official Spotify desktop app appearing in the list while Soloist does not is expected: it is
  already signed in and registered through Spotify's servers. Soloist has not signed in yet.
- The phone must be on the same subnet for the first pairing; guest Wi-Fi, client isolation, or a
  phone VPN will hide the device even with the ports open.
- Soloist's build is valid for 90 days from its build date; an expired build exits with code 10 and
  Spotifast downloads a replacement.
