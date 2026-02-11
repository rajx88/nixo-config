{
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
          language_servers = ["nil" "!nixd"];
        };
      };
      lsp = {
        nil = {
          initialization_options = {
            formatting = {
              command = ["alejandra" "--quiet" "--"];
            };
          };
          settings = {
            diagnostics = {
              ignored = ["unused_binding"];
            };
          };
        };
      };
    };
  };
}
