{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  aws-lc,
}:
rustPlatform.buildRustPackage {
  pname = "switchyard";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "NVIDIA-NeMo";
    repo = "Switchyard";
    rev = "v0.3.0";
    hash = "sha256-NkazY5a2cOZgByjQIp9gtPhLLdxcNpwuAi46OwHfjEs=";
  };

  cargoHash = "sha256-Wzz4PL7XFNG38EwA+LX+Yf2p79j1JH+YMl59rGSu5Mo=";

  # Only the standalone proxy binary; the workspace also holds the Python
  # bindings and relay plugin, which we don't need.
  cargoBuildFlags = [
    "-p"
    "switchyard-server"
  ];

  nativeBuildInputs = [ pkg-config ];
  # nixpkgs' cargo setup hook exports AWS_LC_SYS_USE_SYSTEM=1, so aws-lc-sys
  # links against a system AWS-LC instead of building its vendored copy.
  # Do not add openssl here: its setup hook exports OPENSSL_DIR, which
  # aws-lc-sys probes before pkg-config and would then reject as "not AWS-LC".
  buildInputs = [ aws-lc ];

  # Integration tests hit live providers.
  doCheck = false;

  meta = with lib; {
    description = "NVIDIA NeMo Switchyard: routes LLM agent traffic between efficient and capable models";
    homepage = "https://github.com/NVIDIA-NeMo/Switchyard";
    license = licenses.asl20;
    mainProgram = "switchyard-server";
    platforms = [ "x86_64-linux" ];
  };
}
