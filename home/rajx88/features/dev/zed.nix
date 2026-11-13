{
  pkgs,
  lib,
  ...
}:
let
  mkZshCompletion = import ../../lib/zsh-completion.nix { inherit pkgs lib; };
in
{
  home.packages = [
    # zeditor is zed-editor's CLI; generate its completion at build time.
    (mkZshCompletion "zeditor" pkgs.zed-editor "zeditor" "--completions zsh")
  ];

  home.persistence."/persist" = {
    directories = [
      ".local/share/zed"
      ".config/zed"
    ];
  };

  programs.zed-editor = {
    enable = true;
    userSettings = {
      telemetry = {
        diagnostics = false;
        metrics = false;
      };
      vim_mode = true;
      # base_keymap = "JetBrains";
      ui_font_size = 16;
      buffer_font_size = 15;
      theme = {
        mode = "system";
        light = "Ayu Light";
        dark = "Ayu Dark";
      };
      languages = {
        Nix = {
          language_servers = [
            "nil"
            "!nixd"
          ];
        };
      };
      lsp = {
        nil = {
          initialization_options = {
            formatting = {
              command = [ "nixfmt" ];
            };
          };
          settings = {
            diagnostics = {
              ignored = [ "unused_binding" ];
            };
          };
        };
      };
    };
  };
}
