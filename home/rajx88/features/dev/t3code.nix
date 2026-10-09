{ pkgs, ... }: {
  # T3 Code: conversational multi-agent GUI + `t3` CLI/server. Both are
  # repo-local prebuilt packages (pkgs/t3code from the .deb, pkgs/t3code-cli
  # from the release tarball) so we track upstream without waiting on nixpkgs.
  # Provider CLIs (opencode, claude, cursor) come from the Home PATH.
  home.packages = [
    pkgs.t3code
    pkgs.t3code-cli
  ];

  home.persistence."/persist".directories = [
    ".t3" # server install, worktrees, telemetry
    ".config/t3code" # Electron userData
  ];
}
