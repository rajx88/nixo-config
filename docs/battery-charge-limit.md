# Battery charge limit (Dell Pro Max 16)

## Overview

The battery is limited to about 80% to reduce wear while the laptop is plugged in. The limit
lives **in the Dell firmware** (BIOS storage), not in NixOS. Nothing in this repo sets it, so a
rebuild neither applies nor removes it. The only thing in the repo is the one-off
`battery-full` service (see below).

| Setting      | Value                                   |
| ------------ | --------------------------------------- |
| Mode         | `Custom`                                |
| Start charge | below **75%**                           |
| Stop charge  | about **80%**                           |
| Where        | Dell firmware, via `/sys/class/power_supply/BAT0/`  |

How a window works: charging stops once the battery passes the **stop** value. After a stop it
only starts again when the level drops below the **start** value. In between (75-80%) the
battery sits idle on AC. Lowering the limit never discharges the battery on AC; it just stops
charging.

## Re-apply it (after a BIOS update or reset)

Check the current state first:

```bash
cat /sys/class/power_supply/BAT0/charge_types
cat /sys/class/power_supply/BAT0/charge_control_{start,end}_threshold
```

It should show `[Custom]` and `75` / `80`. If not, set it again. **Order matters**: when raising
the stop value, write the stop first; when lowering, write the start first. From the Dell
defaults (50 / 90) either order works for this pair:

```bash
echo 75 | sudo tee /sys/class/power_supply/BAT0/charge_control_start_threshold
echo 80 | sudo tee /sys/class/power_supply/BAT0/charge_control_end_threshold
echo Custom | sudo tee /sys/class/power_supply/BAT0/charge_types
```

Verify:

```bash
cat /sys/class/power_supply/BAT0/charge_types                          # ... [Custom]
cat /sys/class/power_supply/BAT0/charge_control_{start,end}_threshold  # 75 and 80
```

Writing new thresholds seemed to make the battery charge up to the new stop value once, even
though it was already between start and stop (seen once, not fully explained). It is harmless:
it still stops at the stop value.

### Or set it in the BIOS

F2 at the Dell logo, then Power -> Battery Configuration -> Custom, then Custom Charge Start /
Custom Charge Stop.

## Symptoms that it was reset

| What you see | Likely cause |
| ------------ | ------------ |
| Charges to 100% again | Mode went back to `Adaptive` or `Standard` |
| Stops charging at ~74% and never restarts | Values went back to Dell's defaults, 50 / 90 |
| `charge_types` shows something other than `[Custom]` | Either of the above |

## Dell's rules (why the numbers look like this)

From the kernel driver, `drivers/platform/x86/dell/dell-laptop.c`:

- Start must be between **50 and 95**.
- Stop must be between **55 and 100**.
- Stop must be **at least 5 above** start. A write that breaks this is silently changed to
  fit, e.g. start 79 with stop 80 reads back as 75.

So a stop of 80 can never start charging above 75, and the 75-80% band stays idle on AC. Any
pair works as long as stop = start + 5 or more, for example 80 / 85 (charges whenever under
80%, but caps at 85%).

## Charge to 100% once

`battery-full` is a one-off systemd service defined in `hosts/yuji/default.nix`. It switches the
mode to `Standard` (charges to 100%), waits until the battery reads 100% or the adapter is
unplugged, then switches back to `Custom`. It never runs on its own.

```bash
sudo systemctl start battery-full     # start charging to 100%
systemctl status battery-full         # see whether it is still running
sudo systemctl stop battery-full      # cancel early, limit is restored
```

- It stops by itself at 100%, on unplug, or after 12 hours, and restores `Custom` each time.
- Afterwards the battery just stays at 100% on AC; it is not drained back to 80%. The limit
  applies the next time it charges.
- The stored 75 / 80 values were still there while the mode was `Standard`, so switching back
  to `Custom` should turn them on again. If they read back wrong, re-apply them with the
  commands above.
- If the laptop loses power or crashes while it runs, nothing restores `Custom` and the
  firmware keeps `Standard`. You would notice it charging past 80%. Re-apply the limit with
  the commands above.

## Don't use Noctalia's charging toggle

The "Use charge thresholds" switch in Noctalia's control center asks UPower to write its own
limit into the firmware. That is what caused the original problem: it set 50 / 90, and the
laptop would not charge at 74%. Noctalia shows the switch greyed out ("Set by another tool")
while a limit is active.

Noctalia only reads the limit when it starts, so after changing the firmware it can keep
showing the old state. Trust the `cat` output, and log out and back in to refresh it.
If the bar is ever missing, log out and back in rather than restarting Noctalia by hand.

## Troubleshooting

| Problem | Check |
| ------- | ----- |
| Thresholds read back wrong | Raising stop: write stop first. Lowering: write start first |
| Mode will not stay on `Custom` | Check the BIOS Battery Configuration screen |
| Not sure what the firmware has | `cat /sys/class/power_supply/BAT0/charge_types` shows the active mode in brackets |
| `battery-full` seems stuck | `systemctl status battery-full`; `sudo systemctl stop battery-full` restores the limit |
