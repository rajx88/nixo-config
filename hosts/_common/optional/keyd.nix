# Caps Lock sends Escape on the keyboards this laptop uses.
#
# Done at the evdev layer with keyd rather than in firmware: Akko's multi-mode
# boards are CompX/ROYUAN, not QMK, so there is no VIA/Oryx equivalent for them.
# The ZSA is remapped in its own firmware instead (see zsa.nix) and is
# deliberately not listed here.
#
# keyd matches on vendor:product, so this covers exactly these devices and
# only while they are present:
#   3151:4003 - the Akko, both of its HID keyboard interfaces
#   0001:0001 - the internal keyboard (generic i8042 id)
#
# Over Bluetooth the Akko enumerates under a different vid:pid and this rule
# stops matching; read the id from `sudo keyd monitor` in wireless mode and add
# it to `ids` if that matters.
{ pkgs, ... }:
{
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [
        "3151:4003"
        "0001:0001"
      ];
      settings.main.capslock = "esc";
    };
  };

  # `keyd monitor` / `keyd reload` for poking at ids and config live.
  environment.systemPackages = [ pkgs.keyd ];
}
