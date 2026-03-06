{
  config,
  pkgs,
  ...
}: {
  imports = [./bluetooth.nix];

  environment.systemPackages = [pkgs.brightnessctl];

  # Configure logind to suspend on lid close
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  systemd.services.set-brightness = {
    description = "Set screen brightness to 100% on boot";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.brightnessctl}/bin/brightnessctl -s set 100%";
      User = "root";
    };
  };
}
