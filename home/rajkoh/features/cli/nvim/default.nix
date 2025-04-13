{pkgs, ...}: {
  home.sessionVariables.EDITOR = "nvim";

  home.persistence = {
    "/persist/home/rajkoh".directories = [
      ".config/nvim"
      ".local/share/nvim"
      ".supermaven"
    ];
  };

  # home.packages = with pkgs; [
  #   stylua
  # ];

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    plugins = [
      {
        plugin = pkgs.vimPlugins.sqlite-lua;
        config = "let g:sqlite_clib_path = '${pkgs.sqlite.out}/lib/libsqlite3.so'";
      }
    ];
    extraPackages = with pkgs; [
      # essentials
      git
      fzf
      ripgrep
      tree-sitter
      fswatch # File watcher utility, replacing libuv.fs_event for neovim 10.0
      lazygit
      sqlite

      # build tools
      #cargo
      gcc
      nodejs

      # LSP's and formatters
      ## shell
      nodePackages.bash-language-server
      shellcheck
      shfmt

      # java
      jdt-language-server

      # go
      gopls
      gotools
      gofumpt

      templ

      # nix
      nil
      alejandra

      ## Lua
      stylua
      lua-language-server
      # luajitPackages.luarocks-nix

      ## yaml json etc.
      vscode-langservers-extracted
      yaml-language-server
      prettierd
    ];
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
