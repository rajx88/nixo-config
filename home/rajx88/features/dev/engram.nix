{pkgs, ...}: {
  home.packages = [pkgs.engram];

  home.persistence."/persist".directories = [
    ".engram"
  ];

  programs.fish.completions.engram = ''
    # Subcommand names are pulled live from `engram --help` instead of
    # hardcoded, so new/renamed subcommands show up with no edits here.
    function __engram_commands
      engram --help 2>/dev/null | string match -rg '^  ([a-z][a-z-]*)\s' | string match -v engram | sort -u
    end

    complete -c engram -f
    complete -c engram -n "not __fish_seen_subcommand_from (__engram_commands)" -a "(__engram_commands)"
  '';
}
