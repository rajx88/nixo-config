{
  config,
  pkgs,
  ...
}:
{
  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings = {
    Policy.AutoEnable = "true";
    General = {
      FastConnectable = "true";
      Experimental = "true";
    };
  };
  environment.systemPackages = with pkgs; [
    bluez
  ];
  environment.persistence."/persist".directories = [ "/var/lib/bluetooth" ];
}
