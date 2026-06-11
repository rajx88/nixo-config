{pkgs, config, ...}: let
  pacEnabled = config.programs.proxy.pac.enable or false;
  pacUrl = config.programs.proxy.pac.url or "";
  braveOriginWrapped =
    if pacEnabled
    then
      pkgs.symlinkJoin {
        name = "brave-origin-with-pac";
        paths = [pkgs.brave-origin];
        buildInputs = [pkgs.makeWrapper];
        postBuild = ''
          wrapProgram $out/bin/brave-origin \
            --add-flags "--proxy-pac-url=${pacUrl}"
        '';
      }
    else pkgs.brave-origin;
in {
  home.packages = [braveOriginWrapped];

  home.persistence."/persist".directories = [".config/BraveSoftware/Brave-Origin"];
}
