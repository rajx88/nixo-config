{pkgs, ...}: {
  programs.fzf = {
    enable = true;
    tmux.enableShellIntegration = true;
  };

  programs.sesh = {
    enable = true;
    enableAlias = false;
    tmuxKey = "C-f";
    enableTmuxIntegration = false;
  };

  programs.zsh = {
    zsh-abbr.abbreviations = {
      s = "sesh";
    };
  };

  home.packages = with pkgs; [
    gum
  ];

  programs.tmux = {
    enable = true;
    clock24 = false;

    prefix = "C-a";

    baseIndex = 1;
    newSession = false;
    # Stop tmux+escape craziness.
    escapeTime = 0;
    # keyMode = "vi";
    mouse = true;

    extraConfig = ''

      set -ga terminal-overrides ",screen-256color*:Tc"
      set-option -g default-terminal "screen-256color"
      set -s escape-time 0

      unbind C-b
      set-option -g prefix C-a
      bind-key C-a send-prefix
      set -g status-style 'bg=#333333 fg=#5eacd3'

      bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded"
      set -g base-index 1

      set-window-option -g mode-keys vi
      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'xclip -in -selection clipboard'

      # vim-like pane switching
      bind -r ^ last-window
      bind -r k select-pane -U
      bind -r j select-pane -D
      bind -r h select-pane -L
      bind -r l select-pane -R

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

      # adding sesh options

      bind-key x kill-pane # skip "kill-pane 1? (y/n)" prompt
      set -g detach-on-destroy off  # don't exit from tmux when closing a session

      bind-key "K" display-popup -E -w 40% "sesh connect \"$(
       sesh list -i | gum filter --limit 1 --no-sort --fuzzy --placeholder 'Pick a sesh' --height 50 --prompt='⚡ '
      )\""

      bind-key "C-f" run-shell "sesh connect \"$(
      sesh list --icons | fzf-tmux -p 81%,70% \
      --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
      --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
      --bind 'tab:down,btab:up' \
      --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
      --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
      --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
      --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
      --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
      --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
      --preview-window 'right:55%' \
      --preview 'sesh preview {}'
      )\""

    '';
  };
}
