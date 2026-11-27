# Handy from upstream's prebuilt release (.deb) instead of compiling it.
#
# The github:cjpais/Handy flake rebuilds Rust + bun on every nixpkgs bump and
# has no binary cache, so it was recompiled on each system update. Upstream's
# release CI ships the same Tauri deb bundle (binary + bundled ggml/whisper libs
# + resources), so unpack that and only fix up ELF paths here. Bump with
# `./pkgs/update.sh handy`.
{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  wrapGAppsHook4,
  symlinkJoin,
  alsa-plugins,
  alsa-lib,
  openblas,
  pipewire,
  webkitgtk_4_1,
  gtk3,
  glib,
  glib-networking,
  libsoup_3,
  libayatana-appindicator,
  libevdev,
  libxtst,
  libx11,
  libxi,
  gtk-layer-shell,
  openssl,
  vulkan-loader,
  wtype,
  dotool,
  wl-clipboard,
  gst_all_1,
}:
let
  pname = "handy";
  version = "0.10.2";

  # Loaded with dlopen() at runtime (tray, input injection, Vulkan backend), so
  # they never appear in NEEDED and autoPatchelf cannot add them to RUNPATH.
  runtimeLibs = [
    libayatana-appindicator
    libevdev
    libxtst
    libx11
    libxi
    vulkan-loader
    openblas
  ];

  gstPlugins = with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
  ];

  # PipeWire's and alsa-plugins' ALSA modules live in separate roots; Handy
  # expects a single directory of plugins (same layout the upstream flake uses).
  alsaPluginDir = symlinkJoin {
    name = "handy-alsa-plugins";
    paths = [
      "${pipewire}/lib/alsa-lib"
      "${alsa-plugins}/lib/alsa-lib"
    ];
  };
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/cjpais/Handy/releases/download/v${version}/Handy_${version}_amd64.deb";
    hash = "sha256-sAaLa4lxp4QqA2LXre/aekkaIIYFBn7jvxcRdYIApbQ=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    wrapGAppsHook4
  ];

  buildInputs = [
    alsa-lib
    glib
    glib-networking
    gtk3
    gtk-layer-shell
    libsoup_3
    openssl
    webkitgtk_4_1
  ]
  ++ gstPlugins
  ++ runtimeLibs;

  # A .deb is an ar archive, not a tarball.
  unpackPhase = ''
    runHook preUnpack
    dpkg-deb --fsys-tarfile $src | tar -x --no-same-owner
    runHook postUnpack
  '';

  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -a usr/. $out/
    runHook postInstall
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}"
      --set ALSA_PLUGIN_DIR "${alsaPluginDir}"
      # The store is immutable, so the in-app updater cannot work.
      --set HANDY_DISABLE_UPDATER 1
      # Wayland text injection (wtype) and clipboard fallback (wl-clipboard).
      --suffix PATH : ${
        lib.makeBinPath [
          wtype
          dotool
          wl-clipboard
        ]
      }
    )
  '';

  meta = {
    description = "Offline speech-to-text app (prebuilt upstream release)";
    homepage = "https://github.com/cjpais/Handy";
    changelog = "https://github.com/cjpais/Handy/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "handy";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
