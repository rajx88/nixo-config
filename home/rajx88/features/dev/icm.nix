{pkgs, ...}: {
  home.packages = [pkgs.icm];

  # LLM-backed consolidation via Codex CLI over the OpenCode Go subscription
  # (see features/dev/codex.nix). Falls back to lexical concat without it.
  home.file.".config/icm/config.toml".text = ''
    [consolidate.summarizer]
    provider = "codex"
    model = "gpt-5.6-luna"
  '';

  home.persistence."/persist".directories = [
    ".local/share/icm"
  ];
}
