{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  glib-networking,
  gtk3,
  libdrm,
  libgbm,
  libGL,
  libkrb5,
  libpulseaudio,
  libuuid,
  libx11,
  libxcb,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxkbcommon,
  libxkbfile,
  libxrandr,
  libxrender,
  libxscrnsaver,
  libxshmfence,
  libxtst,
  nspr,
  nss,
  pango,
  pipewire,
  udev,
  wayland,
  zlib,
}:
let
  pname = "ao";
  version = "0.13.5";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/OrchestratorInc/agent-orchestrator/releases/download/v${version}/agent-orchestrator-linux-x64.deb";
    hash = "sha256-M22K7yuBL0O8r4ipeaKasi9SaMdz1o/jXMWnCPVkhxY=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    glib-networking
    gtk3
    libdrm
    libgbm
    libx11
    libxkbcommon
    libxscrnsaver
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxrandr
    libxrender
    libxshmfence
    libxtst
    libuuid
    nspr
    nss
    pango
    pipewire
    udev
    wayland
    libxcb
    zlib
    libkrb5
    libxkbfile
    libGL
    libpulseaudio
  ];

  dontConfigure = true;
  dontBuild = true;
  # Keep the vendored Electron/Go/Node/tmux binaries intact.
  dontStrip = true;

  # The Electron main binary resolves libffmpeg.so / libEGL.so / libGLESv2.so
  # relative to itself ($ORIGIN), and several helper binaries (Go daemon, tmux,
  # browser sidecar, embedded Node) vendor libraries that autoPatchelf cannot
  # resolve from buildInputs. Preserve $ORIGIN and tolerate the rest.
  appendRunpaths = [ "$ORIGIN" ];
  autoPatchelfIgnoreMissingDeps = true;

  unpackPhase = ''
    ar x $src
    tar xf data.tar.* --no-same-permissions --no-same-owner
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib $out/bin $out/share
    cp -r usr/lib/agent-orchestrator $out/lib/agent-orchestrator
    cp -r usr/share/applications $out/share/applications
    cp -r usr/share/pixmaps $out/share/pixmaps

    # Nix cannot carry a setuid chrome-sandbox, so launch with --no-sandbox.
    makeWrapper $out/lib/agent-orchestrator/agent-orchestrator \
      $out/bin/agent-orchestrator \
      --add-flags "--no-sandbox" \
      --inherit-argv0

    substituteInPlace $out/share/applications/agent-orchestrator.desktop \
      --replace-fail "Exec=agent-orchestrator" "Exec=agent-orchestrator --no-sandbox"

    runHook postInstall
  '';

  meta = {
    description = "Orchestrate teams of coding agents from planning to merge (Electron desktop app)";
    homepage = "https://orchestrator.inc";
    downloadPage = "https://github.com/OrchestratorInc/agent-orchestrator/releases";
    license = lib.licenses.asl20;
    mainProgram = "agent-orchestrator";
    platforms = [ "x86_64-linux" ];
  };
}
