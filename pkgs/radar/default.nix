{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:
let
  version = "1.8.1";
  srcs = {
    x86_64-linux = fetchurl {
      url = "https://github.com/skyhook-io/radar/releases/download/v${version}/radar_v${version}_linux_amd64.tar.gz";
      hash = "sha256-5B7pxKy2mRGBevWQfd40Q4ReJORAc929tBcV2O5K3Og=";
    };
    aarch64-linux = fetchurl {
      url = "https://github.com/skyhook-io/radar/releases/download/v${version}/radar_v${version}_linux_arm64.tar.gz";
      hash = "sha256-3J+H2k2YSQSOwQhkXpGSDZwlKF5+1C1KhrS+hbkIstY=";
    };
  };
in
stdenv.mkDerivation {
  pname = "radar";
  inherit version;

  src = srcs.${stdenv.hostPlatform.system};

  sourceRoot = ".";

  nativeBuildInputs = [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall
    install -Dm755 kubectl-radar $out/bin/kubectl-radar
    ln -s $out/bin/kubectl-radar $out/bin/radar
    runHook postInstall
  '';

  meta = {
    description = "Modern Kubernetes visibility — topology, traffic, and Helm management";
    homepage = "https://radarhq.io";
    license = lib.licenses.asl20;
    mainProgram = "kubectl-radar";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
