{
  lib,
  stdenv,
  fetchurl,
  ripgrep,
  makeWrapper,
  glibc,
}:
stdenv.mkDerivation rec {
  pname = "opencode";
  version = "1.14.28";

  src = fetchurl {
    url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-linux-x64.tar.gz";
    hash = "sha256-P5pxOWEtRCGkZAjUbu7Se9lYvb5/Q1FM1eWhCtFUDls=";
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
    install -Dm755 opencode $out/bin/.opencode-unwrapped
    patchelf --set-interpreter ${glibc}/lib/ld-linux-x86-64.so.2 $out/bin/.opencode-unwrapped
    makeWrapper $out/bin/.opencode-unwrapped $out/bin/opencode \
      --prefix PATH : ${lib.makeBinPath [ripgrep]}
    runHook postInstall
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "The open source coding agent";
    homepage = "https://opencode.ai/";
    license = lib.licenses.mit;
    mainProgram = "opencode";
    platforms = ["x86_64-linux"];
  };
}
