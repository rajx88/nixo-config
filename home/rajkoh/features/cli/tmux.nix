{pkgs, ...}: {
  # programs.sesh = {
  #   enable = true;
  # };
  programs.tmux = {
    enable = true;
    clock24 = false;

    prefix = "C-a";

    baseIndex = 1;
    newSession = false;
    # Stop tmux+escape craziness.
    escapeTime = 0;
    keyMode = "vi";
    mouse = true;

    # plugins = with pkgs; [
    # set some default keybindings, e.g. prefix + r for reload
    # for more information go to https://github.com/tmux-plugins/tmux-sensible
    # tmuxPlugins.sensible
    # resurrect and continuum
    # tmuxPlugins.resurrect
    # {
    #   plugin = tmuxPlugins.continuum;
    #   extraConfig = ''
    #     set -g @continuum-restore 'on'
    #     set -g @continuum-save-interval '60' # minutes
    #   '';
    # }
    # tmuxPlugins.vim-tmux-navigator
    # tmuxPlugins.open

    # styling
    # {
    #   plugin = tmuxPlugins.catppuccin;
    #   extraConfig = ''
    #     set -g @catppuccin_flavour 'mocha'
    #     set -g @catppuccin_pill_theme_enabled on
    #   '';
    # }
    # ];

    extraConfig = ''

      #########################################
      ####        general tmux options     ####
      #########################################
      set -ga terminal-overrides ",screen-256color*:Tc"
      set-option -g default-terminal "screen-256color"

      set -g status-style 'bg=#333333 fg=#5eacd3'

      # Allow tmux to set the terminal title
      set -g set-titles on

      # re-number windows when one is closed
      set -g renumber-windows on

      ############################
      ####        binds       ####
      ############################
      # Split windows
      unbind %
      unbind '"'
      bind \\ split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # bind control Y to sync panes
      bind C-Y set-window-option synchronize-panes

      # Easier and faster switching between next/prev window
      bind C-p previous-window
      bind C-n next-window

      # Source .tmux.conf as suggested in `man tmux`
      bind R source-file '~/.config/tmux/tmux.conf'

      ###################################
      ####        vim keybinds       ####
      ###################################

      set-window-option -g mode-keys vi
      bind -r ^ last-window
      bind -r k select-pane -U
      bind -r j select-pane -D
      bind -r h select-pane -L
      bind -r l select-pane -R

      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'xclip -in -selection clipboard'

    '';
  };
}
