# Hindsight — server-side memory backend for OMP (oh-my-pi)
# https://github.com/vectorize-io/hindsight
#
# OMP config (already set):
#   memory.backend = hindsight
#   hindsight.apiUrl = http://localhost:8888   (default)
#
# SETUP: Before enabling, create the secrets file once:
#   sudo mkdir -p /hindsight
#   sudo tee /hindsight/env <<'EOF'
#   HINDSIGHT_API_LLM_PROVIDER=groq
#   HINDSIGHT_API_LLM_API_KEY=gsk_xxxxxxxxxxxx
#   HINDSIGHT_API_LLM_MODEL=llama-3.3-70b-versatile
#   EOF
#   sudo chmod 600 /hindsight/env
#
# Other supported providers: openai, anthropic, gemini, ollama, none
# See: https://hindsight.vectorize.io/developer/configuration
#
# API:  http://localhost:8888
# UI:   http://localhost:9999
{...}: {
  # Declare /hindsight as a persisted directory so impermanence creates the
  # btrfs mount (subvol=/persist/hindsight → /hindsight). Without this the
  # cleanup script flags /persist/hindsight as an unmounted stray.
  host.filesystem.impermanence.directories = ["/hindsight"];

  # Create the data subdirectory before the container starts.
  # Impermanence creates /persist/hindsight itself; we only need the subdir.
  systemd.tmpfiles.settings."hindsight"."/hindsight/data" = {
    d = {
      mode = "0700";
      user = "1000";
      group = "1000";
    };
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers.hindsight = {
      image = "ghcr.io/vectorize-io/hindsight:latest";

      # Loopback-only — Hindsight has no built-in auth.
      ports = [
        "127.0.0.1:8888:8888" # API (what OMP calls)
        "127.0.0.1:9999:9999" # Web UI
      ];

      # /hindsight is the impermanence bind mount of /persist/hindsight.
      volumes = [
        "/hindsight/data:/home/hindsight/.pg0"
      ];

      # LLM provider credentials — kept outside the Nix store.
      environmentFiles = [
        "/hindsight/env"
      ];
    };
  };
}
