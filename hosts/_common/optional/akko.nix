# Akko (ROYUAN "Multi-modes Keyboard-B") — Caps Lock sends Escape.
#
# Done at the evdev layer with keyd rather than in firmware: Akko's multi-mode
# boards are CompX/ROYUAN, not QMK, so there is no VIA/Oryx equivalent for them.
#
# keyd matches on vendor:product, so this applies only while the Akko is
# plugged in — the internal keyboard and the ZSA (remapped in its own firmware,
# see zsa.nix) keep their own Caps Lock. Both HID keyboard interfaces of the
# board report the same id, so keyd grabs both.
#
# Over Bluetooth the board enumerates under a different vid:pid and this rule
# stops matching; read the id from `sudo keyd monitor` in wireless mode and add
# it to `ids` if that matters.
{ pkgs, ... }:
{
  services.keyd = {
    enable = true;
    keyboards.akko = {
      ids = [ "3151:4003" ];
      settings.main.capslock = "esc";
    };
  };

  # `keyd monitor` / `keyd reload` for poking at ids and config live.
  environment.systemPackages = [ pkgs.keyd ];
}
