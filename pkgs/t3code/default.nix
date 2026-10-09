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
  libsecret,
  libdrm,
  libgbm,
  libGL,
  libglvnd,
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
  pname = "t3code";
  version = "0.0.45";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/T3-Code-${version}-amd64.deb";
    hash = "sha256-aEvJF5EaW9lK56Hjczg4S69yx66r648RyWqcY1sp43U=";
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
    libsecret
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
    libglvnd
    libpulseaudio
  ];

  dontConfigure = true;
  dontBuild = true;
  # Keep the vendored Electron/native helper binaries intact.
  dontStrip = true;

  # Electron resolves libffmpeg.so/libEGL.so relative to itself ($ORIGIN); the
  # capture/resource-monitor/browser-secret sidecars vendor their own libs.
  appendRunpaths = [ "$ORIGIN" ];
  autoPatchelfIgnoreMissingDeps = true;

  unpackPhase = ''
    ar x $src
    tar xf data.tar.* --no-same-permissions --no-same-owner
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib $out/bin $out/share
    cp -r "opt/T3 Code (Alpha)" $out/lib/t3code
    cp -r usr/share/icons $out/share/icons
    cp -r usr/share/applications $out/share/applications

    # Nix cannot carry a setuid chrome-sandbox, so launch with --no-sandbox.
    # The upstream .deb ships no bundled ANGLE (libEGL.so/libGLESv2.so), so
    # Electron falls back to native EGL. Put libglvnd's libEGL.so.1 (vendor
    # dispatch) and the NixOS driver libs on the loader path, otherwise EGL
    # init fails and Chromium silently switches to software rendering (laggy).
    makeWrapper $out/lib/t3code/t3code $out/bin/t3code-desktop \
      --add-flags "--no-sandbox" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libglvnd ]}" \
      --suffix LD_LIBRARY_PATH : "/run/opengl-driver/lib" \
      --inherit-argv0

    substituteInPlace $out/share/applications/t3code.desktop \
      --replace-fail '"/opt/T3 Code (Alpha)/t3code"' "t3code-desktop" \
      --replace-fail "Name=T3 Code (Alpha)" "Name=T3 Code"

    runHook postInstall
  '';

  meta = {
    description = "Open-source control plane for coding agents (Electron desktop app)";
    homepage = "https://t3.codes";
    downloadPage = "https://github.com/pingdotgg/t3code/releases";
    changelog = "https://github.com/pingdotgg/t3code/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "t3code-desktop";
    platforms = [ "x86_64-linux" ];
  };
}
