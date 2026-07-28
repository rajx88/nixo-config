{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
}:
rustPlatform.buildRustPackage {
  pname = "icm";
  version = "0.10.61";

  src = fetchFromGitHub {
    owner = "rtk-ai";
    repo = "icm";
    rev = "icm-v0.10.61";
    hash = "sha256-dIZxq29umqRt81g0Y7RY90oAgf+ockrKfwPvFd8k8tU=";
  };

  cargoHash = "sha256-1YZ1GYnRxxbXXIG7d0+Nd8z2MhL8JQuuLexWNCmA+Ic=";

  nativeBuildInputs = [pkg-config];

  buildInputs = [openssl];

  cargoBuildFlags = [
    "--no-default-features"
    "--features=tui,http-api,backend-sqlite"
  ];

  doCheck = false;

  meta = with lib; {
    description = "Permanent memory for AI agents. Single binary, zero dependencies, MCP native.";
    homepage = "https://github.com/rtk-ai/icm";
    license = licenses.asl20;
    mainProgram = "icm";
  };
}
