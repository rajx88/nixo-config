{
  config,
  pkgs,
  ...
}: {
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  environment.systemPackages = with pkgs; [blueman bluez];
  environment.persistence."/persist".directories = ["/var/lib/bluetooth"];
}
