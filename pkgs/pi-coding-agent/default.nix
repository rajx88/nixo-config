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
  pname = "pi-coding-agent";
  version = "0.75.5";

  src = fetchurl {
    url = "https://github.com/earendil-works/pi/releases/download/v${version}/pi-linux-x64.tar.gz";
    hash = "sha256-rGh6zXJwXavpZ/1A02Uxf2gFSHi+HLLArpoFkv0Qi10=";
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
    cp -r pi $out/lib/pi
    mv $out/lib/pi/pi $out/lib/pi/.pi-unwrapped
    patchelf --set-interpreter ${glibc}/lib/ld-linux-x86-64.so.2 $out/lib/pi/.pi-unwrapped
    makeWrapper $out/lib/pi/.pi-unwrapped $out/bin/pi \
      --prefix PATH : ${lib.makeBinPath [ripgrep git]}
    runHook postInstall
  '';

  meta = {
    description = "Minimal terminal coding agent";
    homepage = "https://shittycodingagent.ai";
    license = lib.licenses.mit;
    mainProgram = "pi";
    platforms = ["x86_64-linux"];
  };
}
