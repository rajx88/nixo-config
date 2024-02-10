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

  # home.packages = with pkgs; [
  #   stylua
  # ];

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      # essentials
      nodejs
      gcc
      tree-sitter
      git
      wget
      curl
      lazygit
      ripgrep
      fd
      unzip
      gzip

      # LSP's and formatters
      ## shell
      # shellcheck
      # shfmt
      # beautysh

      ## Lua
      stylua
      lua-language-server
      # luajitPackages.luarocks-nix

      ## yaml json etc.
      prettierd
      # ansible-lint
      # eslint_d
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
