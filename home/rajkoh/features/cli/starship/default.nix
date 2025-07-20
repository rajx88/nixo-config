{
  pkgs,
  config,
  lib,
  ...
}: {
  xdg.configFile."starship" = {
    source = ./config;
    recursive = true;
  };

  # home.sessionVariables.STARSHIP_CONFIG = "${config.xdg.configHome}/starship/starship.toml";

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    # settings = {
    #   # format = lib.concatStrings [
    #   #   "[](bg:#030B16 fg:#7DF9AA)"
    #   #   "[ ](bg:#7DF9AA fg:#090c0c)"
    #   #   "[](fg:#7DF9AA bg:#1C3A5E)"
    #   #   "$time"
    #   #   "[](fg:#1C3A5E bg:#3B76F0)"
    #   #   "$directory"
    #   #   "[](fg:#3B76F0 bg:#FCF392)"
    #   #   "$git_branch"
    #   #   "$git_status"
    #   #   "$git_metrics"
    #   #   "[](fg:#FCF392)"
    #   #   "$line_break"
    #   #   "$character"
    #   # ];
    #   format = '''
    #      [](bg:#030B16 fg:#7DF9AA)\
    #      [ ](bg:#7DF9AA fg:#090c0c)\
    #      [](fg:#7DF9AA bg:#1C3A5E)\
    #      $time\
    #      [](fg:#1C3A5E bg:#3B76F0)\
    #      $directory\
    #      [](fg:#3B76F0 bg:#FCF392)\
    #      $git_branch\
    #      $git_status\
    #      $git_metrics\
    #      [](fg:#FCF392 bg:#030B16)
    #      $character
    # ''';
    #
    #   # Disable the blank line at the start of the prompt
    #   add_newline = true;
    #
    #   # palette = "catppuccin_mocha";
    #
    #   command_timeout = 10000;
    #
    #   # username = {
    #   #   show_always = true;
    #   #   style_user = "bg:#9A348E";
    #   #   style_root = "bg:#9A348E";
    #   #   format = "[$user ]($style)";
    #   #   disabled = false;
    #   # };
    #
    #   directory = {
    #     format = "[ ﱮ  $path ]($style)";
    #     style = "fg:#E4E4E4 bg:#3B76F0";
    #   };
    #
    #   git_branch = {
    #     format = "[ $symbol$branch(:$remote_branch) ]($style)";
    #     symbol = "  ";
    #     style = "fg:#1C3A5E bg:#FCF392";
    #   };
    #
    #   git_status = {
    #     format = "[$all_status]($style)";
    #     style = "fg:#1C3A5E bg:#FCF392";
    #   };
    #
    #   git_metrics = {
    #     format = "([+$added]($added_style))[]($added_style)";
    #     added_style = "fg:#1C3A5E bg:#FCF392";
    #     deleted_style = "fg:bright-red bg:235";
    #     disabled = false;
    #   };
    #
    #   hg_branch = {
    #     format = "[ $symbol$branch ]($style)";
    #     symbol = " ";
    #   };
    #
    #   cmd_duration = {
    #     format = "[  $duration ]($style)";
    #     style = "fg:bright-white bg:18";
    #   };
    #
    #   character = {
    #     success_symbol = "[ ➜ ](bold green) ";
    #     # success_symbol = "[ ❯ ](bold green) ";
    #     error_symbol = "[ ✗ ](#E84D44) ";
    #   };
    #
    #   time = {
    #     disabled = false;
    #     time_format = "%R";
    #     style = "bg:#1d2230";
    #     format = "[[ 󱑍 $time ](bg:#1C3A5E fg:#8DFBD2)]($style)";
    #   };
    #
    #   palettes = {
    #     catppuccin_mocha = {
    #       rosewater = "#f5e0dc";
    #       flamingo = "#f2cdcd";
    #       pink = "#f5c2e7";
    #       mauve = "#cba6f7";
    #       red = "#f38ba8";
    #       maroon = "#eba0ac";
    #       peach = "#fab387";
    #       yellow = "#f9e2af";
    #       green = "#a6e3a1";
    #       teal = "#94e2d5";
    #       sky = "#89dceb";
    #       sapphire = "#74c7ec";
    #       blue = "#89b4fa";
    #       lavender = "#b4befe";
    #       text = "#cdd6f4";
    #       subtext1 = "#bac2de";
    #       subtext0 = "#a6adc8";
    #       overlay2 = "#9399b2";
    #       overlay1 = "#7f849c";
    #       overlay0 = "#6c7086";
    #       surface2 = "#585b70";
    #       surface1 = "#45475a";
    #       surface0 = "#313244";
    #       base = "#1e1e2e";
    #       mantle = "#181825";
    #       crust = "#11111b";
    #     };
    #   };
    # };
  };
}
