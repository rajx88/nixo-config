{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
}:
rustPlatform.buildRustPackage {
  pname = "icm";
  version = "0.10.57";

  src = fetchFromGitHub {
    owner = "rtk-ai";
    repo = "icm";
    rev = "icm-v0.10.57";
    hash = "sha256-TcdO+aS4E/SVOYjRkov2im+xAZIA66RHARcGvTZ1/ME=";
  };

  cargoHash = "sha256-misPc3KIi5H8ZlOqAkX8n0y7l8hBvED2/bU1H8Ihnck=";

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
