{
  lib,
  stdenv,
  fetchurl,
  patchelf,
  makeWrapper,
  glibc,
  git,
  ripgrep,
}:
stdenv.mkDerivation rec {
  pname = "copilot-cli";
  version = "1.0.105";

  src = fetchurl {
    url = "https://github.com/github/copilot-cli/releases/download/v${version}/copilot-linux-x64.tar.gz";
    hash = "sha256-q6Hwbye8BEdlZkf3bgpM9YtLKjQcdf8Ep1CYK2rra9I=";
  };

  nativeBuildInputs = [
    patchelf
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
    mkdir -p $out/lib/copilot
    cp copilot $out/lib/copilot/.copilot-unwrapped
    patchelf --set-interpreter ${glibc}/lib/ld-linux-x86-64.so.2 $out/lib/copilot/.copilot-unwrapped
    makeWrapper $out/lib/copilot/.copilot-unwrapped $out/bin/copilot \
      --prefix PATH : ${
        lib.makeBinPath [
          git
          ripgrep
        ]
      } \
      --prefix LD_LIBRARY_PATH : ${stdenv.cc.cc.lib}/lib
    runHook postInstall
  '';

  meta = {
    description = "GitHub Copilot coding agent CLI";
    homepage = "https://github.com/github/copilot-cli";
    license = lib.licenses.unfree;
    mainProgram = "copilot";
    platforms = [ "x86_64-linux" ];
  };
}
