{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  hasPackage = pname: lib.any (p: p ? pname && p.pname == pname) config.home.packages;
  hasEza = hasPackage "eza";
  hasLazyGit = hasPackage "lazygit";
  hasFastFetch = hasPackage "fastfetch";
in {
  home.persistence = {
    "/persist/home/rajkoh".directories = [
      ".config/zsh"
      ".local/completions"
    ];
  };

  programs.zsh = {
    enable = true;
    # set the ZDOTDIR
    dotDir = ".config/zsh";
    enableCompletion = true;

    defaultKeymap = "emacs";

    sessionVariables = {
      MINIKUBE_HOME = "${config.xdg.dataHome}/minikube";
    };

    autocd = true;
    cdpath = [
      "."
      "$HOME"
      "$HOME/code"
      "$HOME/code/prvt"
      "$HOME/code/work"
      "/opt/hawaii/workspace"
    ];

    localVariables = {
      ZSH_INCLUDES = "$ZDOTDIR/includes";
      ZSH_PINCLUDES = "$ZDOTDIR/pincludes";
    };

    profileExtra = ''
      zstyle ':completion:*' menu select

      setopt complete_aliases
      setopt complete_in_word
      setopt glob_complete

      if [[ -d $ZSH_PINCLUDES ]]; then
      	for file in $ZSH_PINCLUDES/*.zsh(DN); do
      		if [[ -f $file && -r $file ]]; then
        	# Source the file
        	source $file
      		fi
      	done
      fi

    '';

    initExtra = ''

      bindkey -M emacs "^[[3~" delete-char
      bindkey -M viins "^[[3~" delete-char
      bindkey -M vicmd "^[[3~" delete-char

      # [Ctrl-Delete] - delete whole forward-word
      bindkey -M emacs '^[[3;5~' kill-word
      bindkey -M viins '^[[3;5~' kill-word
      bindkey -M vicmd '^[[3;5~' kill-word

      # [Ctrl-RightArrow] - move forward one word
      bindkey -M emacs '^[[1;5C' forward-word
      bindkey -M viins '^[[1;5C' forward-word
      bindkey -M vicmd '^[[1;5C' forward-word

      # [Ctrl-LeftArrow] - move backward one word
      bindkey -M emacs '^[[1;5D' backward-word
      bindkey -M viins '^[[1;5D' backward-word
      bindkey -M vicmd '^[[1;5D' backward-word


      typeset -U path PATH
      path=($HOME/.local/bin $path)

      if [[ -d $ZSH_INCLUDES ]]; then
      for file in $ZSH_INCLUDES/*.zsh(DN); do
      	if [[ -f $file && -r $file ]]; then
      		# Source the file
      		source $file
      	fi
      done
      fi
    '';

    initExtraBeforeCompInit = ''
      fpath=($HOME/.local/completions $fpath ${config.xdg.cacheHome}/completions)
    '';

    history = {
      extended = true;
      ignoreDups = true;
      expireDuplicatesFirst = true;
      size = 100000;
      save = 100000;
      path = "${config.xdg.configHome}/zsh/zsh_history";
    };

    shellAliases = {
      # no output
      cd = ">/dev/null cd";

      # zsh file related
      szsh = "source $ZDOTDIR/.zshrc";

      # ls
      ls = mkIf hasEza "eza --icons";
      #  ll="eza --icons --group-directories-first -al"
      ll = mkIf hasEza "eza --icons -abghHliS";
      tree = mkIf hasEza "eza --icons --tree -abghHliS";

      grep = "grep --color";

      # gradle related
      gw = "./gradlew";
    };

    zsh-abbr = {
      enable = true;
      # initExtra =
      abbreviations = {
        asdfup = "asdf plugin update --all";

        jqless = "jq -C | less -r";

        lg = mkIf hasLazyGit "lazygit";

        ff = mkIf hasFastFetch "fastfetch";

        # git
        gs = "git s";
        gc = "git c";
        gall = "git all";
        gpu = "git pu";
        gco = "git co";
        gcb = "git cob";

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
        gwcb = "gw clean build";
        gwcheck = "gw checkstyleMain pmdMain spotbugsMain --continue";
        gwcc = "gw clean checkstyleMain pmdMain spotbugsMain --continue";
        gwc = "gw clean compileJava";
        gwp = "gw --no-configuration-cache clean publishToMavenLocal";
      };
    };

    zplug = {
      enable = true;
      zplugHome = "${config.xdg.configHome}/zsh/zplug";
      plugins = [
        {name = "zsh-users/zsh-autosuggestions";}
        {name = "zsh-users/zsh-syntax-highlighting";}
        {name = "zsh-users/zsh-completions";}
        {name = "romkatv/zsh-defer";}
        {name = "mafredri/zsh-async, from:github";}
        # {name = "sindresorhus/pure, use:pure.zsh, from:github, as:theme";}
        # {name = "plugins/command-not-found, from:oh-my-zsh, as:plugin";}
        # { name = "olets/zsh-abbr"; }
        # {name = "Tarrasch/zsh-bd"; }
      ];
    };
  };
}
