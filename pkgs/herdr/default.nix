{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "herdr";
  version = "0.8.0";

  src = fetchurl {
    url = "https://github.com/herdrdev/herdr/releases/download/v${version}/herdr-linux-x86_64";
    hash = "sha256-uHLqfkD6LLF+hXrJtisb8m23tAPGIvXS8/WzX26azSg=";
  };

  dontUnpack = true;
  dontBuild = true;
  dontPatchELF = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/herdr
    runHook postInstall
  '';

  meta = {
    description = "Agent multiplexer that lives in your terminal";
    homepage = "https://herdr.dev";
    license = lib.licenses.mit;
    mainProgram = "herdr";
    platforms = ["x86_64-linux"];
  };
}
