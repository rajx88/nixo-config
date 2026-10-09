{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
}:
let
  pname = "t3code-cli";
  version = "0.0.45";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/t3-${version}-linux-x64.tar.gz";
    hash = "sha256-EFBa50vGpDz6sP3gvwag4NaGL3QDBZG+mUpkDUig1r0=";
  };

  # The release root is the directory the `t3` Node-SEA binary resolves its
  # sibling client/ and node_modules/ against, so keep it intact.
  sourceRoot = "t3-${version}-linux-x64";

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    stdenv.cc.cc.lib
  ];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  # Native addons (node-pty, keyring, ffi-rs) resolve sibling libs via $ORIGIN.
  appendRunpaths = [ "$ORIGIN" ];
  autoPatchelfIgnoreMissingDeps = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib $out/bin
    cp -r . $out/lib/t3code-cli

    # process.execPath must stay inside the release dir so the binary finds
    # its client/ and node_modules/ siblings.
    makeWrapper $out/lib/t3code-cli/t3 $out/bin/t3 --inherit-argv0

    runHook postInstall
  '';

  meta = {
    description = "T3 Code CLI and server (headless control plane for coding agents)";
    homepage = "https://t3.codes";
    downloadPage = "https://github.com/pingdotgg/t3code/releases";
    changelog = "https://github.com/pingdotgg/t3code/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "t3";
    platforms = [ "x86_64-linux" ];
  };
}
