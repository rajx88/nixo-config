{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  glibc,
  gcc-unwrapped,
  git,
}:
stdenv.mkDerivation rec {
  pname = "codegraph";
  version = "1.1.6";

  src = fetchurl {
    url = "https://github.com/colbymchenry/codegraph/releases/download/v${version}/codegraph-linux-x64.tar.gz";
    hash = "sha256-+rfx9stB8oJkiLRBHy68Ntp5km0ryg04IPT1EKvP0UM=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  dontBuild = true;
  dontPatchELF = true;
  dontStrip = true;

  unpackPhase = ''
    tar xzf $src
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib $out/bin
    cp -r codegraph-linux-x64 $out/lib/codegraph
    patchelf --set-interpreter ${glibc}/lib/ld-linux-x86-64.so.2 \
      --set-rpath ${lib.makeLibraryPath [gcc-unwrapped.lib glibc]} \
      $out/lib/codegraph/node
    makeWrapper $out/lib/codegraph/bin/codegraph $out/bin/codegraph \
      --prefix PATH : ${lib.makeBinPath [git]}
    runHook postInstall
  '';

  meta = {
    description = "Pre-indexed code knowledge graph for AI coding agents — fewer tokens, fewer tool calls, 100% local";
    homepage = "https://github.com/colbymchenry/codegraph";
    license = lib.licenses.mit;
    mainProgram = "codegraph";
    platforms = ["x86_64-linux"];
  };
}
