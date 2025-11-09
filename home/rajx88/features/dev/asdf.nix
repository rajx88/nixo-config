{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    asdf-vm
  ];

  programs.zsh = {
    initContent = ''
      export ASDF_DATA_DIR="${config.xdg.configHome}/asdf"

      . "$HOME/.nix-profile/share/asdf-vm/asdf.sh"

      [[ ! -f "$ASDF_DATA_DIR/plugins/java/set-java-home.zsh" ]] || . "$ASDF_DATA_DIR/plugins/java/set-java-home.zsh"
    '';
  };
}
