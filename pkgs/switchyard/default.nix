{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
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
  buildInputs = [ openssl ];

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
