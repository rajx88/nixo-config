{pkgs, ...}: {
  imports = [
    ./lutris.nix
    ./steam.nix
  ];

  home = {
    packages = with pkgs; [gamescope];
    persistence = {
      "/persist/home/rajx88" = {
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
