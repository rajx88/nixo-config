{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
}:
rustPlatform.buildRustPackage {
  pname = "icm";
  version = "0.10.62";

  src = fetchFromGitHub {
    owner = "rtk-ai";
    repo = "icm";
    rev = "icm-v0.10.62";
    hash = "sha256-n7PhghO95ZY/fKftbfrN97itoix+67clyIZG+W2LIG8=";
  };

  cargoHash = "sha256-f+j9SmxI046GFscyBwuZxwMZOtUk3cTePlCI6QIa+xw=";

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
