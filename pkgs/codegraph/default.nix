{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  git,
  nodejs_24,
}:
stdenv.mkDerivation rec {
  pname = "codegraph";
  version = "1.6.2";

  src = fetchurl {
    url = "https://github.com/colbymchenry/codegraph/releases/download/v${version}/codegraph-linux-x64.tar.gz";
    hash = "sha256-7wr0FgkhKPsczHI3hgALft9KaXH+YErNCL+Wbk83uCg=";
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
    cp -r codegraph-linux-x64 $out/lib/codegraph

    # Upstream ships a prebuilt `node` that is a non-PIE (ET_EXEC) binary
    # hard-wired to load at a low fixed address. The glibc 2.44 loader
    # segfaults (SIGSEGV/SEGV_ACCERR) while bootstrapping it, so every
    # `codegraph` invocation dies instantly -- including `ldd` and
    # `--version`. This reproduces only on newer kernels (observed broken
    # on 7.2.11, working on 7.2.9/7.2.10) and is independent of the
    # environment, so it is the bundled node build, not the config.
    #
    # Swap it for the distro nodejs_24, which is PIE and loads at a high
    # randomized base. CodeGraph's own node-version-check requires
    # Node >= 20 and explicitly blocks Node 25+ (V8 turboshaft WASM Zone
    # OOM), so 24 is the right major to pin to.
    rm $out/lib/codegraph/node
    ln -s ${nodejs_24}/bin/node $out/lib/codegraph/node

    makeWrapper $out/lib/codegraph/bin/codegraph $out/bin/codegraph \
      --prefix PATH : ${lib.makeBinPath [ git ]}
    runHook postInstall
  '';

  meta = {
    description = "Pre-indexed code knowledge graph for AI coding agents — fewer tokens, fewer tool calls, 100% local";
    homepage = "https://github.com/colbymchenry/codegraph";
    license = lib.licenses.mit;
    mainProgram = "codegraph";
    platforms = [ "x86_64-linux" ];
  };
}
