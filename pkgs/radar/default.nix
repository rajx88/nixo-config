{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:
let
  version = "1.13.0";
in
stdenv.mkDerivation {
  pname = "radar";
  inherit version;

  src = fetchurl {
    url = "https://github.com/skyhook-io/radar/releases/download/v${version}/radar_v${version}_linux_amd64.tar.gz";
    hash = "sha256-vMZO6l4jJXFv24IUEa+lW7H0Dc6Xm84Yjwk01s/k50I=";
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
