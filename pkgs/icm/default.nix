{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
}:
stdenv.mkDerivation rec {
  pname = "icm";
  version = "0.11.4";

  # Prebuilt release asset instead of a source build: compiling this crate with
  # its vendored deps took ~15 minutes per run, and that cost was paid on every
  # CI run because the hosted store is cold each time.
  #
  # The glibc asset, not `-musl`: the embeddings feature dlopens onnxruntime at
  # runtime, which a static musl binary cannot do.
  #
  # Hash matches the entry published in the release's checksums.txt:
  #   319e619e809cc80e033b56dfb7ec5977ad886d1a13f9db2ab82022a9ecaca376
  src = fetchurl {
    url = "https://github.com/rtk-ai/icm/releases/download/icm-v${version}/icm-x86_64-unknown-linux-gnu.tar.gz";
    hash = "sha256-MZ5hnoCcyA4DO1bft+xZd62IbRoT+dsquCAiqeyso3Y=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  # libgcc_s.so.1 is in the binary's NEEDED list; autoPatchelfHook resolves it
  # from here (libc/libm come from the stdenv).
  buildInputs = [ stdenv.cc.cc.lib ];

  dontBuild = true;
  dontStrip = true;

  # The tarball holds a single file at its root, so there is no directory for
  # unpackPhase to infer as the source root.
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 icm $out/bin/icm
    runHook postInstall
  '';

  # The embeddings-dynamic build dlopens onnxruntime (downloaded at runtime by
  # `icm embeddings download`). That shared lib needs libstdc++.so.6, but it
  # ships its own RUNPATH, so the icm binary's rpath is NOT consulted for its
  # transitive deps — only LD_LIBRARY_PATH is. Without this, every
  # embed/recall-with-vectors call fails with "onnxruntime runtime not found"
  # on NixOS. (issue #345)
  #
  # postFixup rather than postInstall: the wrapper must be created after
  # autoPatchelfHook has retargeted the interpreter in fixupPhase.
  postFixup = ''
    wrapProgram $out/bin/icm \
      --prefix LD_LIBRARY_PATH : ${stdenv.cc.cc.lib}/lib
  '';

  meta = with lib; {
    description = "Permanent memory for AI agents. Single binary, zero dependencies, MCP native.";
    homepage = "https://github.com/rtk-ai/icm";
    license = licenses.asl20;
    mainProgram = "icm";
    platforms = [ "x86_64-linux" ];
  };
}
