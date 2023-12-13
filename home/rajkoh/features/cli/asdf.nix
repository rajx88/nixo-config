{ pkgs, config, ... }: 
{

  # home.file.".tool-versions".text = ''
  #   kubectl 1.28.4
  # '';

  home.packages = with pkgs; [
    asdf-vm
  ];

  programs.zsh = {
    enable = true;
    initExtra = ''
      [[ ! -f "${config.xdg.dataHome}/asdf/plugins/java/set-java-home.zsh" ]] || . "${config.xdg.dataHome}/asdf/plugins/java/set-java-home.zsh"
    '';

    # initExtraBeforeCompInit = ''
    #   [[ ! -f "${config.xdg.dataHome}/asdf/asdf.sh" ]] || . "${config.xdg.dataHome}/asdf/asdf.sh"

    #   # append completions to fpath
    #   fpath=($fpath ${config.xdg.dataHome}/asdf/completions)
    # '';
  };
}
