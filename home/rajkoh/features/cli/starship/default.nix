{pkgs, ...}:
{
  programs.starship = {
    enable = true;
    # Configuration written to ~/.config/starship.toml
    settings = pkgs.lib.importTOML ./config/starship.toml;
  };
}
