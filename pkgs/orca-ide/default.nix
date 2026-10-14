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
  libglvnd,
  libkrb5,
  libnotify,
  libpulseaudio,
  libsecret,
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
  git,
  openssh,
  python3,
  wl-clipboard,
  xclip,
  xdotool,
  xdg-utils,
  xvfb,
}:
let
  pname = "orca-ide";
  version = "1.4.225";

  # The app shells out to python for notebook kernels and to the X11/Wayland
  # clipboard + input tools for its computer-use path (declared as Depends in
  # the upstream control file: python3, python3-gi, gir1.2-atspi-2.0, xdotool,
  # xclip, xvfb, xdg-utils). pygobject3 + at-spi2-core's GIR keep the
  # accessibility-driven half of that working.
  pythonEnv = python3.withPackages (ps: [ ps.pygobject3 ]);

  runtimePath = lib.makeBinPath [
    git
    openssh
    xdg-utils
    xdotool
    xclip
    wl-clipboard
    xvfb
    pythonEnv
  ];

  # libglvnd's vendor-dispatch libEGL.so.1 plus the NVIDIA driver libs, so the
  # bundled ANGLE (libEGL.so/libGLESv2.so) reaches the real driver instead of
  # falling back to swiftshader.
  gpuLibPath = "${lib.makeLibraryPath [ libglvnd ]}:/run/opengl-driver/lib";

  # Electron's Linux notification backend dlopen()s libnotify at runtime
  # (shell/browser/notifications/linux/libnotify_notification.cc). autoPatchelfHook
  # only sees DT_NEEDED entries, so a dlopen() target is never recorded and must be
  # put on the loader search path by hand: without it dlopen fails, Electron logs
  # "Unable to find libnotify; notifications disabled", Notification.isSupported()
  # returns false, and Orca reports "this system does not support notifications" —
  # no agent-completion notification and no notification sound.
  notificationLibPath = "${lib.getLib libnotify}/lib";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/stablyai/orca/releases/download/v${version}/orca-ide_${version}_amd64.deb";
    hash = "sha256-14k1CfTCQtFBNCR/tu71uwas3RMgzQbBrdKb0cdHUA4=";
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
    libGL
    libglvnd
    libkrb5
    libnotify
    libpulseaudio
    libsecret
    libuuid
    libx11
    libxcb
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxkbcommon
    libxkbfile
    libxrandr
    libxrender
    libxscrnsaver
    libxshmfence
    libxtst
    nspr
    nss
    pango
    pipewire
    udev
    wayland
    zlib
    # node-pty, @parcel/watcher and sherpa-onnx ship prebuilt .node objects
    # linked against libstdc++/libgcc_s; without these in the search path the
    # terminals and the file watcher fail to load.
    stdenv.cc.cc.lib
  ];

  dontConfigure = true;
  dontBuild = true;
  # Keep the vendored Electron/prebuilt .node objects intact.
  dontStrip = true;

  # The Electron binary resolves libffmpeg.so / libEGL.so / libGLESv2.so /
  # libvulkan.so.1 relative to itself ($ORIGIN), and sherpa-onnx's .node finds
  # libsherpa-onnx-c-api.so the same way, so autoPatchelf must not drop $ORIGIN.
  appendRunpaths = [ "$ORIGIN" ];
  autoPatchelfIgnoreMissingDeps = [ "*" ];

  unpackPhase = ''
    ar x $src
    tar xf data.tar.* --no-same-permissions --no-same-owner
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib $out/bin $out/share
    cp -r opt/Orca $out/lib/orca-ide
    cp -r usr/share/icons $out/share/icons
    cp -r usr/share/applications $out/share/applications

    # GUI. Nix cannot carry a setuid chrome-sandbox, so launch with
    # --no-sandbox, like the other Electron packages here. Orca additionally
    # appends --disable-gpu-sandbox itself whenever it detects a Wayland
    # session (XDG_SESSION_TYPE=wayland), which is what both hosts run.
    makeWrapper $out/lib/orca-ide/orca-ide $out/bin/orca-desktop \
      --add-flags "--no-sandbox" \
      --inherit-argv0 \
      --prefix LD_LIBRARY_PATH : "${gpuLibPath}" \
      --prefix LD_LIBRARY_PATH : "${notificationLibPath}" \
      --prefix GI_TYPELIB_PATH : "${lib.getLib at-spi2-core}/lib/girepository-1.0" \
      --prefix PATH : "${runtimePath}"

    # CLI. Upstream names the Linux CLI `orca-ide` so it does not collide with
    # the GNOME Orca screen reader. The bundled shim resolves the app directory
    # relative to itself and runs Electron in Node mode
    # (ELECTRON_RUN_AS_NODE=1), so it needs the same library path but no
    # display and no sandbox flags.
    makeWrapper $out/lib/orca-ide/resources/bin/orca-ide $out/bin/orca-ide \
      --prefix LD_LIBRARY_PATH : "${gpuLibPath}" \
      --prefix LD_LIBRARY_PATH : "${notificationLibPath}" \
      --prefix PATH : "${runtimePath}"

    substituteInPlace $out/share/applications/orca-ide.desktop \
      --replace-fail 'Exec=/opt/Orca/orca-ide' 'Exec=orca-desktop'

    runHook postInstall
  '';

  meta = {
    description = "ADE / control plane for a fleet of parallel coding agents (Electron desktop app)";
    homepage = "https://github.com/stablyai/orca";
    downloadPage = "https://github.com/stablyai/orca/releases";
    changelog = "https://github.com/stablyai/orca/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "orca-ide";
    platforms = [ "x86_64-linux" ];
  };
}
