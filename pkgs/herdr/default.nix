{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "herdr";
  version = "0.9.2";

  src = fetchurl {
    url = "https://github.com/herdrdev/herdr/releases/download/v${version}/herdr-linux-x86_64";
    hash = "sha256-dN40dG+WI2921Zn49dJDn4hDUeq+JbdJXg7at1QUBko=";
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
