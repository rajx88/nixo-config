{
  lib,
  stdenv,
  fetchurl,
  ripgrep,
  patchelf,
  glibc,
}:
stdenv.mkDerivation rec {
  pname = "opencode";
  version = "2.3.0";

  # v2 publishes no GitHub release assets; the prebuilt CLI binary is served
  # from opencode.ai's own CDN, version-pinned and immutable. The manifest at
  # https://opencode.ai/update/api/latest/cli/opencode records the version and
  # sha256 for each artifact (see pkgs/update.sh). Asset layout matches v1: a
  # root-level `opencode` binary, so installPhase is unchanged.
  src = fetchurl {
    url = "https://opencode.ai/files/bin/${version}/opencode-linux-x64.tar.gz";
    hash = "sha256-/A+BUirO6rrEdpPYg4nvorxRfOdMLDj9aWeBn8xuTTs=";
  };

  nativeBuildInputs = [
    patchelf
  ];

  dontBuild = true;
  dontPatchELF = true;
  dontStrip = true;

  # The CLI embeds @parcel/watcher as a Bun `/$bunfs/root/watcher-*.node`
  # module and extracts it to /tmp before dlopen'ing it for recursive
  # directory watches. That module links libstdc++.so.6, which NixOS does not
  # put on a default library path. The extracted module is not a dependency
  # of the executable, so the executable's DT_RUNPATH is not consulted and
  # the dlopen fails; opencode then logs "watcher backend not supported" for
  # every directory watch (file watches fall back to node's non-recursive
  # fs.watch and keep working). DT_RPATH, unlike DT_RUNPATH, is also used for
  # transitive/dlopen dependencies, so point it at the C++ runtime the
  # embedded module needs.
  cxxLib = lib.getLib stdenv.cc.cc;

  unpackPhase = ''
    tar xzf $src
  '';

  # The real binary must be installed as `opencode` (not hidden behind a
  # rename + wrapper) so its process basename is recognized by external
  # tooling that matches on the executable name, e.g. herdr's agent
  # detection. A wrapper that execs a differently named binary would make
  # argv[0] the hidden name and defeat that detection.
  installPhase = ''
    runHook preInstall
    install -Dm755 opencode $out/bin/opencode
    patchelf --set-interpreter ${glibc}/lib/ld-linux-x86-64.so.2 $out/bin/opencode
    # See cxxLib above: this must be DT_RPATH (--force-rpath), not RUNPATH, so
    # the dlopen'd @parcel/watcher module resolves libstdc++.so.6.
    patchelf --force-rpath --set-rpath ${cxxLib}/lib $out/bin/opencode
    # opencode looks for `rg` on PATH and downloads its own copy if missing.
    # Exposing ripgrep from the package's own bin dir keeps it self-contained
    # without a wrapper (a wrapper would rename the process and break agent
    # detection, e.g. herdr matching the `opencode` executable name).
    ln -s ${lib.getExe ripgrep} $out/bin/rg
    runHook postInstall
  '';

  meta = {
    description = "The open source coding agent";
    homepage = "https://opencode.ai/";
    license = lib.licenses.mit;
    mainProgram = "opencode";
    platforms = [ "x86_64-linux" ];
  };
}
