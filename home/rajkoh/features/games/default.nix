{pkgs, ...}: {
  imports = [
    ./lutris.nix
    ./steam.nix
  ];

  home = {
    packages = with pkgs; [gamescope];
    persistence = {
      "/persist/home/rajkoh" = {
        allowOther = true;
        directories = [
          {
            directory = "Games";
            method = "symlink";
          }
        ];
      };
    };
  };
}
