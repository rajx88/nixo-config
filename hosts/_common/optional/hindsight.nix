# Hindsight — server-side memory backend for OMP (oh-my-pi)
# https://github.com/vectorize-io/hindsight
#
# Architecture: two containers on Docker bridge "hindsight":
#   hindsight-llama  ghcr.io/ggml-org/llama.cpp:server-cuda  (port 8080, internal only)
#   hindsight        ghcr.io/vectorize-io/hindsight:latest    (port 8888 API, 9999 UI)
#
# GPU: NVIDIA RTX PRO 1000 Blackwell (GB207, sm_120) via CUDA 12.8.1.
# Image server-cuda uses CUDA 12.8.1 — NOT server-cuda13 (CUDA 13.3 generates broken
# GPU code for sm_120). GPU access via `--gpus all`; requires both
# hardware.nvidia-container-toolkit.enable and virtualisation.docker.enableNvidia in yuji.
#
# Model (~3.5 GB GGUF) auto-downloaded from HuggingFace on first start.
# Cached in /hindsight/llama-models (persisted via impermanence).
# No external API key required.
#
# OMP config (already set):
#   memory.backend   = hindsight
#   hindsight.apiUrl = http://localhost:8888
#
# API: http://localhost:8888
# UI:  http://localhost:9999
{pkgs, ...}: {
  host.filesystem.impermanence.directories = ["/hindsight"];

  systemd.tmpfiles.settings."hindsight" = {
    "/hindsight/data".d         = { mode = "0700"; user = "1000"; group = "1000"; };
    "/hindsight/llama-models".d = { mode = "0755"; user = "root"; group = "root"; };
  };

  # Shared Docker bridge so hindsight reaches hindsight-llama by hostname.
  systemd.services.docker-network-hindsight = {
    description = "Create hindsight Docker bridge network";
    after    = [ "docker.service" ];
    requires = [ "docker.service" ];
    before   = [ "docker-hindsight-llama.service" "docker-hindsight.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type            = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.bash}/bin/sh -c '${pkgs.docker}/bin/docker network inspect hindsight >/dev/null 2>&1 || ${pkgs.docker}/bin/docker network create hindsight'";
      ExecStop  = "${pkgs.bash}/bin/sh -c '${pkgs.docker}/bin/docker network rm hindsight 2>/dev/null || true'";
    };
  };

  systemd.services.docker-hindsight-llama.after    = [ "docker-network-hindsight.service" ];
  systemd.services.docker-hindsight-llama.requires = [ "docker-network-hindsight.service" ];
  systemd.services.docker-hindsight.after  = [ "docker-network-hindsight.service" "docker-hindsight-llama.service" ];
  systemd.services.docker-hindsight.wants  = [ "docker-hindsight-llama.service" ];

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {

      # llama.cpp sidecar — CUDA 12.8.1 (server-cuda), NOT server-cuda13 (broken sm_120).
      hindsight-llama = {
        image = "ghcr.io/ggml-org/llama.cpp:server-cuda";
        volumes = [ "/hindsight/llama-models:/root/.cache/huggingface" ];
        environment = {
          LLAMA_ARG_HOST         = "0.0.0.0";
          LLAMA_ARG_PORT         = "8080";
          LLAMA_ARG_HF_REPO      = "bartowski/google_gemma-4-E2B-it-GGUF";
          LLAMA_ARG_HF_FILE      = "google_gemma-4-E2B-it-Q4_K_M.gguf";
          LLAMA_ARG_CTX_SIZE     = "16384";  # total pool; per-slot = 16384/2 = 8192 tokens
          LLAMA_ARG_N_GPU_LAYERS = "999";
          LLAMA_ARG_N_PARALLEL   = "2";      # batched decode: weights read once → 2 tokens
          LLAMA_ARG_FLASH_ATTN   = "on";     # fused attention: stable multi-slot perf
          LLAMA_ARG_CACHE_TYPE_K = "q8_0";   # halve KV cache bandwidth
          LLAMA_ARG_CACHE_TYPE_V = "q8_0";
        };
        extraOptions = [
          "--network=hindsight"
          "--gpus=all"
        ];
      };

      hindsight = {
        image = "ghcr.io/vectorize-io/hindsight:latest";
        ports = [
          "127.0.0.1:8888:8888"   # API
          "127.0.0.1:9999:9999"   # Web UI
        ];
        volumes = [ "/hindsight/data:/home/hindsight/.pg0" ];
        environment = {
          HINDSIGHT_API_LLM_PROVIDER = "openai";
          HINDSIGHT_API_LLM_BASE_URL = "http://hindsight-llama:8080/v1";
          HINDSIGHT_API_LLM_API_KEY  = "not-needed";
          HINDSIGHT_API_LLM_MODEL    = "gemma-4-e2b-it";
        };
        extraOptions = [ "--network=hindsight" ];
      };

    };
  };
}
