{
  config,
  inputs,
  ...
}: let
  isClean = inputs.self ? rev;
in {
  system.autoUpgrade = {
    enable = isClean;
    dates = "hourly";
    flags = [
      "--update-input"
      "nixpkgs"
      "-L" # print build logs
    ];
    flake = inputs.self.outPath;
  };
}
