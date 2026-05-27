{pkgs, ...}: {
  home.packages = with pkgs; [
    prmt
  ];

  programs.zsh = {
    initContent = ''
      setopt PROMPT_SUBST

      # Git ahead/behind tracking for prmt prompt
      function _prmt_git_sync() {
        PRMT_GIT_SYNC=""
        # Only run in git repos
        if git rev-parse --is-inside-work-tree &>/dev/null; then
          local output
          output=$(git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null)
          if [[ $? -eq 0 && -n "$output" ]]; then
            local ahead behind
            ahead=$(echo "$output" | cut -f1)
            behind=$(echo "$output" | cut -f2)
            local sync=""
            [[ $ahead -gt 0 ]] && sync+="$ahead⇡"
            [[ $behind -gt 0 ]] && sync+="$behind⇣"
            PRMT_GIT_SYNC="$sync"
          fi
        fi
        export PRMT_GIT_SYNC
      }
      typeset -ga precmd_functions
      precmd_functions+=(_prmt_git_sync)

      PROMPT='$(prmt --shell zsh --code $? " {path:#89dceb} {git:#f9e2af:f: } {env:#f38ba8:PRMT_GIT_SYNC} {time:dim:24hs} \n{ok:#a6e3a1}{fail:#f38ba8} ")'
    '';
  };

  programs.fish.functions = {
    _prmt_git_sync = {
      body = ''
        set -gx PRMT_GIT_SYNC ""
        if git rev-parse --is-inside-work-tree &>/dev/null
          set -l output (git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null)
          if test $status -eq 0 -a -n "$output"
            set -l ahead (echo $output | cut -f1)
            set -l behind (echo $output | cut -f2)
            set -l sync ""
            if test $ahead -gt 0
              set sync "$ahead⇡"
            end
            if test $behind -gt 0
              set sync "$sync$behind⇣"
            end
            set -gx PRMT_GIT_SYNC $sync
          end
        end
      '';
    };

    fish_prompt = {
      body = ''
        set -l last_status $status
        _prmt_git_sync
        prmt --shell none --code $last_status "{path:#89dceb} {git:#f9e2af:f: } {env:#f38ba8:PRMT_GIT_SYNC} {time:dim:24hs} {ok:#a6e3a1:>}{fail:#f38ba8:>} "
      '';
    };
  };
}
