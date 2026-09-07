{
  lib,
  stdenv,
  fetchurl,
  ripgrep,
  git,
  makeWrapper,
  glibc,
}:
stdenv.mkDerivation rec {
  pname = "omp";
  version = "18.1.14";

  src = fetchurl {
    url = "https://github.com/can1357/oh-my-pi/releases/download/v${version}/omp-linux-x64";
    hash = "sha256-J91my2osOf/1Hh/m20Dx83b+5KPQRFfyNu2qXQKQ5NI=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  dontBuild = true;
  dontPatchELF = true;
  dontStrip = true;
  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/.omp-unwrapped
    patchelf --set-interpreter ${glibc}/lib/ld-linux-x86-64.so.2 $out/bin/.omp-unwrapped
    makeWrapper $out/bin/.omp-unwrapped $out/bin/omp \
      --prefix PATH : ${lib.makeBinPath [ripgrep git]}
    runHook postInstall
  '';

  meta = {
    description = "AI coding agent for the terminal — hash-anchored edits, LSP, debugger, subagents";
    homepage = "https://omp.sh";
    license = lib.licenses.mit;
    mainProgram = "omp";
    platforms = ["x86_64-linux"];
  };
}
