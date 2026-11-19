{ inputs, pkgs, ... }:
{
  imports = [ inputs.luciole.homeModules.default ];

  programs.luciole = {
    enable = true;
    package = pkgs.luciole;
  };

  # Open folders with Luciole by default.
  xdg.mimeApps.defaultApplications."inode/directory" = [ "dev.noctalia.luciole.desktop" ];
}
