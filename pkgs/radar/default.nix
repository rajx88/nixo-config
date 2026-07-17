{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:
let
  version = "1.8.3";
in
stdenv.mkDerivation {
  pname = "radar";
  inherit version;

  src = fetchurl {
    url = "https://github.com/skyhook-io/radar/releases/download/v${version}/radar_v${version}_linux_amd64.tar.gz";
    hash = "sha256-ZDU73MgUk5fm4Uc5ybxcxm5kTD2NbKsc1m55c0Mq/V4=";
  };

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
    platforms = [ "x86_64-linux" ];
  };
}
