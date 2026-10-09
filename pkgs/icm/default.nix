{
  lib,
  pkgs,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
}:
rustPlatform.buildRustPackage {
  pname = "icm";
  version = "0.11.4";

  src = fetchFromGitHub {
    owner = "rtk-ai";
    repo = "icm";
    rev = "icm-v0.11.4";
    hash = "sha256-iihIM/MVAR5zmFIzo5oUgtOkOCf8474W/AwrbJUVkno=";
  };

  cargoHash = "sha256-5TQWLYCsNO/MNNCwlVXwV3NyDQrB/mq0eB8utoOsLw0=";

  nativeBuildInputs = [
    pkg-config
    pkgs.makeWrapper
  ];

  buildInputs = [ openssl ];

  cargoBuildFlags = [
    "--no-default-features"
    "--features=embeddings-dynamic,tui,http-api,backend-sqlite"
  ];

  doCheck = false;

  # The embeddings-dynamic build dlopens onnxruntime (downloaded at runtime by
  # `icm embeddings download`). That shared lib needs libstdc++.so.6, but it
  # ships its own RUNPATH, so the icm binary's rpath is NOT consulted for its
  # transitive deps — only LD_LIBRARY_PATH is. Without this, every
  # embed/recall-with-vectors call fails with "onnxruntime runtime not found"
  # on NixOS. (issue #345)
  postInstall = ''
    wrapProgram $out/bin/icm \
      --prefix LD_LIBRARY_PATH : ${pkgs.stdenv.cc.cc.lib}/lib
  '';

  meta = with lib; {
    description = "Permanent memory for AI agents. Single binary, zero dependencies, MCP native.";
    homepage = "https://github.com/rtk-ai/icm";
    license = licenses.asl20;
    mainProgram = "icm";
  };
}
