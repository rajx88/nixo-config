{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:
let
  version = "1.3.8";
in
stdenv.mkDerivation {
  pname = "twg";
  inherit version;

  src = fetchurl {
    url = "https://teamwork-graph.atlassian.com/cli/twg-linux-x64-v${version}";
    hash = "sha256-yfWfgOpj3sSpG3QnF2UK+XYp9Xc81jrul7xMq9IRc2E=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  dontUnpack = true;
  dontBuild = true;
  dontStrip = true;

  # Ships as a raw glibc-linked ELF (a Node 26 single-executable bundle), not an
  # archive. autoPatchelfHook retargets the interpreter at nixpkgs' glibc.
  # No CA certs are needed: Node >= 23 defaults to its bundled Mozilla CA store.
  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/twg
    runHook postInstall
  '';

  meta = {
    description = "Atlassian Teamwork Graph CLI — agent-first context across Jira, Confluence and Bitbucket";
    homepage = "https://teamworkgraph.com/cli";
    license = lib.licenses.unfree;
    mainProgram = "twg";
    platforms = [ "x86_64-linux" ];
  };
}
