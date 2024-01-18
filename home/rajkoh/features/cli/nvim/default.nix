{
  config,
  pkgs,
  ...
}: {
  home.sessionVariables.EDITOR = "nvim";

  home.persistence = {
    "/persist/home/rajkoh".directories = [
      ".config/nvim"
      ".local/share/nvim"
    ];
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      efm-langserver
      nodejs
      go
      gcc
      cargo
      rustc

      # Nix
      nil
      alejandra
      statix

      # go
      golangci-lint

      # shell
      shellcheck
      shfmt
      beautysh

      # Lua
      stylua
      luajitPackages.luarocks-nix

      # Python
      # pyright
      # python-debug
      # black

      # Typescript
      # nodePackages.typescript-language-server

      # docker
      hadolint

      # yaml json etc.
      ansible-lint
      prettierd
      eslint_d
      nodePackages_latest.fixjson

      # Telescope tools
      ripgrep
      fd
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
