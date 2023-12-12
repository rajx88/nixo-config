{ pkgs, lib, config, ... }:
let
  inherit (lib) mkIf;
  hasPackage = pname: lib.any (p: p ? pname && p.pname == pname) config.home.packages;
  hasRipgrep = hasPackage "ripgrep";
  hasEza = hasPackage "eza";
  hasNeovim = config.programs.neovim.enable;
in
{

  programs.zsh= {
    enable = true;
    # set the ZDOTDIR
    dotDir = ".config/zsh";
    enableCompletion = true;

    sessionVariables = {
      MINIKUBE_HOME = "${config.xdg.dataHome}/minikube";
    };

    autocd = true;
    cdpath = [
      "."
      "$HOME"
    ];

    localVariables = {
      ZSH_INCLUDES= "$ZDOTDIR/includes";
    };

    initExtra = ''
        for file in "$ZSH_INCLUDES"/.*.zsh; do
            source "$file"
        done
      ''
    };

    history = {
      extended = true;
      path = "${config.xdg.dataHome}/zsh/zsh_history";
    };

    shellAliases = {
      # zsh file related
      szsh="source $ZDOTDIR/.zshrc";

      # ls
      ls = mkIf hasEza "eza --icons";
      #  ll="eza --icons --group-directories-first -al"
      ll = mkIf hasEza"eza --icons -abghHliS";
      tree = mkIf hasEza"eza --icons --tree -abghHliS";
 
      grep = "grep --color";
      
      # vim
      vim = mkIf hasNeovim "nvim";   
      vi = "vim";
      v = "vim";

    };

    zsh-abbr = {
      enable = true;
      # initExtra = 
      abbreviations = {

        asdfup="asdf plugin update --all";
        
        jqless = "jq -C | less -r";

        # nix swik
        n = "nix";
        nd = "nix develop -c $SHELL";
        ns = "nix shell";
        nsn = "nix shell nixpkgs#";
        nb = "nix build";
        nbn = "nix build nixpkgs#";
        nf = "nix flake";
        nfu = "nix flake update";

        nr = "nixos-rebuild --flake .";
        nrs = "nixos-rebuild switch --flake .#";
        snr = "sudo nixos-rebuild --flake .";
        snrs = "sudo nixos-rebuild switch --flake .#";
        hm = "home-manager --flake .";
        hms = "home-manager switch --flake .#";

        # code
        c = "code";

        # git
        gs = "git status";
        gc = "git commit -v";
        gall = "git add .";
        gp = "git push";
        gco = "git checkout";
        gcb = "git checkout -b";

        # vagrant
        vup = "vagrant up";
        vh = "vagrant halt";
        vr = "vagrant reload";
        vssh = "vagrant ssh";

        # tmux
        ta = "tmux attach";

        # kubectl commands
        k = "kubectl";
        kga = "kubectl get all";
        kgp = "kubectl get pods";
        kw = "kubectl get pods --watch";
        wk = "watch -n 2 kubectl get pods";
        wkn = "watch -n 2 kubectl get pods --namespace";

        # gradle
        gw = "./gradlew --parallel";
        gwcb = "gw clean build";
        gwb = "gw build";
        gwcheck = "gw checkstyleMain pmdMain spotbugsMain --continue";
        gwcc = "gw clean && gwcheck --continue";
        gwc = "gw clean compileJava";
        gwp = "gw clean publishToMavenLocal";
      };
    };

    zplug = {
      enable = true;
      zplugHome = "${config.xdg.configHome}/zsh/zplug";
      plugins = [
        { name = "zsh-users/zsh-autosuggestions"; }
        { name = "zsh-users/zsh-syntax-highlighting"; }
        { name = "zsh-users/zsh-completions"; }
        { name = "romkatv/zsh-defer"; }
        # { name = "command-not-found"; from = "oh-my-zsh";  as = "plugin"; }
        # { name = "olets/zsh-abbr"; }
        # {name = "Tarrasch/zsh-bd"; }
      ];
    };
  };
}
