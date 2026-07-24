{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:
let
  version = "1.8.6";
in
stdenv.mkDerivation {
  pname = "radar";
  inherit version;

  src = fetchurl {
    url = "https://github.com/skyhook-io/radar/releases/download/v${version}/radar_v${version}_linux_amd64.tar.gz";
    hash = "sha256-RMmBNjxOtXek82rh0FRE2/hYdJXpHhWuAmw1QjVFu6I=";
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
