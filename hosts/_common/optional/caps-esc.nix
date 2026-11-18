# Caps Lock sends Escape on the keyboards this laptop uses.
#
# Two mechanisms, on purpose:
#
#   - The Akko goes through keyd. It has no firmware remapping to lean on
#     (CompX/ROYUAN controller, not QMK), and keyd keeps real layers and
#     hold-tap available if this ever grows past a plain swap.
#
#   - The internal keyboard is a udev/hwdb keycode remap instead. That is the
#     keyboard that must never depend on a userspace daemon, so nothing can
#     hang and swallow the only keyboard on the machine. The trade-off is a
#     static swap: no layers, and a new mapping needs a trigger/replug.
#
# Both are device-scoped and the ZSA (remapped in its own firmware, see zsa.nix)
# is listed nowhere:
#   keyd 3151:4003 - the Akko, both of its HID keyboard interfaces
#   hwdb 0001:0001 - internal keyboard; i8042 runs in translated mode here, so
#                    the kernel reports the set-1 scancode 0x3a for Caps Lock
#
# Over Bluetooth the Akko enumerates under a different id and keyd stops
# matching it; read the id from `sudo keyd monitor` in wireless mode and add it
# to `ids` if that should be covered too.
{ pkgs, ... }:
{
  services.keyd = {
    enable = true;
    keyboards.akko = {
      ids = [ "3151:4003" ];
      settings.main.capslock = "esc";
    };
  };

  services.udev.extraHwdb = ''
    evdev:input:b0011v0001p0001*
     KEYBOARD_KEY_3a=esc
  '';

  # `keyd monitor` / `keyd reload` for poking at ids and config live.
  environment.systemPackages = [ pkgs.keyd ];
}
