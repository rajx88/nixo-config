{pkgs, ...}: {
  home.packages = with pkgs; [
    sheldon
  ];

  home.file.".config/sheldon/plugins.toml".text = ''

    shell = "zsh"

    [plugins]
    [plugins.zsh-defer]
    github = "romkatv/zsh-defer"
    apply = ["source"]

    [plugins.zsh-async]
    github = "mafredri/zsh-async"

    [plugins.zsh-completions]
    github = "zsh-users/zsh-completions"
    apply = ["defer"]

    [plugins.zsh-autosuggestions]
    github = "zsh-users/zsh-autosuggestions"
    use = ["{{ name }}.zsh"]
    apply = ["defer"]

    [plugins.fast-syntax-highlighting]
    github = "zdharma-continuum/fast-syntax-highlighting"
    use = ["fast-syntax-highlighting.plugin.zsh"]
    apply = ["defer"]

    [plugins.zsh-history-substring-search]
    github = "zsh-users/zsh-history-substring-search"
    apply = ["defer"]

    #
    # [plugins.spaceship]
    # github = "spaceship-prompt/spaceship-prompt"

    [templates]
    defer = "{{ hooks?.pre | nl }}{% for file in files %}zsh-defer source \"{{ file }}\"\n{% endfor %}{{ hooks?.post | nl }}"
  '';

  programs.zsh.initExtra = ''
    if which sheldon &>/dev/null; then
            eval "$(sheldon source)"
    fi
  '';
}
