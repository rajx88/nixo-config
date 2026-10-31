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
  version = "0.1.5";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/T3-Code-${version}-amd64.deb";
    hash = "sha256-oczjedd7TutmUPMK5KuRjEJVl+0st0A38hWWyJko+n4=";
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
    cp -r "opt/T3 Code (Beta)" $out/lib/t3code
    cp -r usr/share/icons $out/share/icons
    cp -r usr/share/applications $out/share/applications

    # Nix cannot carry a setuid chrome-sandbox, so launch with --no-sandbox.
    # The upstream .deb ships no bundled ANGLE (libEGL.so/libGLESv2.so), so
    # Electron falls back to native EGL. Put libglvnd's libEGL.so.1 (vendor
    # dispatch) and the NixOS driver libs on the loader path, otherwise EGL
    # init fails and Chromium silently switches to software rendering (laggy).
    #
    # T3CODE_HOME: the app defaults to ~/.t3, but the T3 Code server service
    # owns $XDG_DATA_HOME/t3, and session variables do not reach apps launched
    # by the compositor. Default it here so both always resolve to the same
    # home. Local-environment spawning is disabled in Settings -> Connections,
    # which is what keeps closing the app from stopping the server.
    # Auto-update is off because the version is pinned by Nix.
    #
    # D-Bus: Electron's safeStorage needs the session bus. Launched without one
    # (systemd context, a T3 terminal, any scrubbed environment) it still
    # reports backend "gnome_libsecret" but isEncryptionAvailable() is false,
    # so pairing fails with "Desktop secure storage is unavailable in this
    # system context". Point it at the user bus when it is missing.
    #
    # libsecret: the app's Electron dlopens libsecret-1.so.0 at runtime, which
    # autoPatchelfHook cannot see (no DT_NEEDED), so the .deb's binary has no
    # libsecret in its RUNPATH. Without it safeStorage still *claims* the
    # gnome_libsecret backend but refuses to encrypt. Keep it explicitly on the
    # loader path.
    makeWrapper $out/lib/t3code/t3code $out/bin/t3code-desktop \
      --add-flags "--no-sandbox" \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          libglvnd
          libsecret
        ]
      }" \
      --suffix LD_LIBRARY_PATH : "/run/opengl-driver/lib" \
      --set T3CODE_DISABLE_AUTO_UPDATE true \
      --set T3CODE_DESKTOP_LAUNCHER_PATH "$out/bin/t3code-desktop" \
      --run 'T3CODE_HOME="''${T3CODE_HOME:-''${XDG_DATA_HOME:-$HOME/.local/share}/t3}"; export T3CODE_HOME' \
      --run '
        case "''${DBUS_SESSION_BUS_ADDRESS:-}" in
          "" | disabled:)
            DBUS_SESSION_BUS_ADDRESS="unix:path=''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/bus"
            export DBUS_SESSION_BUS_ADDRESS
            ;;
        esac' \
      --inherit-argv0

    substituteInPlace $out/share/applications/t3code.desktop \
      --replace-fail '"/opt/T3 Code (Beta)/t3code"' "t3code-desktop" \
      --replace-fail "Name=T3 Code (Beta)" "Name=T3 Code"

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
