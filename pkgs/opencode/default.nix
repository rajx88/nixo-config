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
  version = "2.0.16";

  # v2 binaries are no longer published as GitHub release assets (the
  # v2.x releases on github.com only carry the auto-generated source
  # tarball/zip) -- opencode.ai/files/bin is the actual distribution
  # host for prebuilt binaries as of v2.
  src = fetchurl {
    url = "https://opencode.ai/files/bin/${version}/opencode-linux-x64.tar.gz";
    hash = "sha256-K5zaM6elOH68XTfaR4uny5BSSnaXQa/aTETObNLCgWM=";
  };

  nativeBuildInputs = [
    patchelf
  ];

  dontBuild = true;
  dontPatchELF = true;
  dontStrip = true;

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
    platforms = ["x86_64-linux"];
  };
}
