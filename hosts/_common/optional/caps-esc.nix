# Caps Lock sends Escape on the keyboards this laptop uses.
#
# Done as a udev/hwdb keycode remap, not with a userspace remapper: there is no
# daemon in the input path, so nothing can hang and swallow a keyboard, and a
# wrong entry can only leave the key behaving as it did (replug, or
# `udevadm trigger`, to retry).
#
# Matched per device, so the ZSA (remapped in its own firmware, see zsa.nix) is
# untouched and each binding only applies while that keyboard is present:
#   0001:0001 - internal keyboard; i8042 in translated mode, so the kernel
#               reports the set-1 scancode 0x3a for Caps Lock
#   3151:4003 - the Akko, both HID keyboard interfaces; MSC_SCAN is the HID
#               usage, 0x07 (keyboard page) << 16 | 0x39 (Caps Lock)
#
# Over Bluetooth the Akko enumerates under a different device id and stops
# matching; add that id (from `sudo evtest`) if wireless should be covered too.
{ ... }:
{
  services.udev.extraHwdb = ''
    evdev:input:b0011v0001p0001*
     KEYBOARD_KEY_3a=esc

    evdev:input:b0003v3151p4003*
     KEYBOARD_KEY_70039=esc
  '';
}
