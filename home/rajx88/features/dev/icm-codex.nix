{pkgs, ...}: {
  # LLM-backed consolidation via Codex CLI over the OpenCode Go subscription
  # (see features/dev/codex.nix). Falls back to lexical concat without it.
  home.file.".config/icm/config.toml".text = ''
    [consolidate.summarizer]
    provider = "codex"
    model = "gpt-5.6-luna"

    [memory]
    auto_consolidate_enabled = true
    auto_consolidate_threshold = 100
  '';
}
