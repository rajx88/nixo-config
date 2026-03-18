{
  config,
  pkgs,
  ...
}: {
  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings = {
    Policy.AutoEnable = "true";
    General = {
      FastConnectable = "true";
      Experimental = "true";
    };
  };
  services.blueman.enable = true;
  environment.systemPackages = with pkgs; [blueman bluez];
  environment.persistence."/persist".directories = ["/var/lib/bluetooth"];
}
