{pkgs, ...}: {
  home.sessionVariables.EDITOR = "nvim";

  home.persistence."/persist".directories = [
    ".config/nvim"
    ".local/share/nvim"
  ];

  programs = {
    zsh = {
      shellAliases = {
        nvi = "nvim -u '$NVIM_CONF_NIX/init.lua'";
      };
      sessionVariables = {
        NVIM_CONF_NIX = "$HOME/code/prvt/nixos-config/home/rajx88/features/cli/nvim/config";
      };
    };
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      extraPackages = with pkgs; [
        # essentials
        git
        fzf
        ripgrep
        tree-sitter
        fswatch # File watcher utility, replacing libuv.fs_event for neovim 10.0
        lazygit

        # build tools
        cargo
        gcc
        nodejs
        go
        python3

        # LSP servers
        gopls
        lua-language-server
        nil
        bash-language-server
        yaml-language-server
        vscode-langservers-extracted
        templ
        jsonnet-language-server

        # formatters
        stylua
        alejandra
        gofumpt
        gotools # goimports
        shfmt
        prettierd
        google-java-format
        go-jsonnet # includes jsonnetfmt

        # debug
        delve

        # java runtime (jdtls via Mason needs Java 21+)
        jdk21
      ];
    };
  };

  xdg = {
    configFile."nvim" = {
      source = ./config;
      recursive = true;
    };

    desktopEntries = {
      nvim = {
        name = "Neovim";
        genericName = "Text Editor";
        comment = "Edit text files";
        exec = "nvim %F";
        icon = "nvim";
        mimeType = [
          "text/english"
          "text/plain"
          "text/x-makefile"
          "text/x-c++hdr"
          "text/x-c++src"
          "text/x-chdr"
          "text/x-csrc"
          "text/x-java"
          "text/x-moc"
          "text/x-pascal"
          "text/x-tcl"
          "text/x-tex"
          "application/x-shellscript"
          "text/x-c"
          "text/x-c++"
        ];
        terminal = true;
        type = "Application";
        categories = ["Utility" "TextEditor"];
      };
    };
  };
}
