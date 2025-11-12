{
  config,
  pkgs,
  ...
}: {
  imports = [./bluetooth.nix];
  programs.light.enable = true;

  systemd.services.set-brightness = {
    description = "Set screen brightness to 100% on boot";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.light}/bin/light -S 100";
      User = "root";
    };
  };
}
