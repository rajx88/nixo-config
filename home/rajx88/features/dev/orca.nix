{
  pkgs,
  ...
}:
{
  # Orca (stablyai) — ADE / control plane for a fleet of parallel coding agents.
  # Repo-local prebuilt package from the upstream .deb (pkgs/orca-ide), so it
  # tracks upstream without waiting on nixpkgs. It drives the agent CLIs that
  # are already on the Home PATH (claude, codex, opencode, cursor).
  #
  # Commands:
  #   orca-desktop  GUI (Electron; --no-sandbox, NVIDIA EGL on the loader path)
  #   orca-ide      bundled CLI — upstream names the Linux CLI `orca-ide` to
  #                 avoid colliding with the GNOME Orca screen reader. It talks
  #                 to a running Orca (or `orca-ide serve`) and runs Electron in
  #                 Node mode, so it needs no display.
  #
  # `orca-ide` also registers a shim in ~/.local/bin from Settings → General →
  # Orca CLI. home.sessionPath puts ~/.local/bin ahead of the Nix profile, so
  # that shim wins for the CLI name — it points back into this same store
  # package and resolves its libraries through the binary's RPATH, so both
  # paths behave identically.
  home.packages = [ pkgs.orca-ide ];

  # Electron reads its own userData from $XDG_CONFIG_HOME/<package name>; the
  # packaged app.asar has no productName, so that directory is `orca` (and the
  # pid/lock/runtime handshake files — orcad.lock, orca-runtime.json, daemon/ —
  # live there too). ~/.orca is the CLI home: keybindings.json, saved Bitbucket/
  # Linear/Jira credentials, managed hook installs. $HOME/orca is the workspace
  # root, where the cloned repos and the per-branch worktrees the agents work in
  # actually live (~/orca/workspaces/<repo>/<branch>@@<hash>) — distinct from
  # ~/.orca, so it must be persisted as well or every worktree is lost.
  home.persistence."/persist".directories = [
    ".config/orca" # Electron userData: settings, sign-in, browser profiles, orcad state
    ".orca" # CLI home: keybindings.json, saved credentials, hook installs
    "orca" # workspace root: cloned repos + agent worktrees (orca/workspaces/…)
    ".local/share/orca" # claude-accounts/ and codex-accounts/ account homes
    ".cache/orca" # downloaded runtimes and helpers
    ".cache/orca-updater" # electron-updater cache
  ];
}
