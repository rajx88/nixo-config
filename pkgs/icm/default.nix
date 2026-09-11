{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
}:
rustPlatform.buildRustPackage {
  pname = "icm";
  version = "0.10.65";

  src = fetchFromGitHub {
    owner = "rtk-ai";
    repo = "icm";
    rev = "icm-v0.10.65";
    hash = "sha256-uV2SRnBcd1zYbPr+bH1IzR1rOVveAttAF+CYgRStzWw=";
  };

  cargoHash = "sha256-sHHY/kLp8oxvj3A/2u1G5xuiNV+0NDpFFuQK4CW8VUo=";

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
