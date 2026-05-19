{pkgs, ...}: {
  # Disable USB autosuspend for Focusrite devices so they're reliably
  # detected on boot without needing to re-plug.
  # Focusrite USB vendor ID = 1235
  services.udev.extraRules = ''
    # Focusrite Scarlett — disable autosuspend so device is always available
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="1235", ATTR{power/autosuspend}="-1"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="1235", ATTR{power/control}="on"
  '';
}
