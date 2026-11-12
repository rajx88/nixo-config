{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  autoPatchelfHook,
  wrapGAppsHook4,
  zstd,
  gcc,
  gtk4,
  gtk4-layer-shell,
  graphene,
  cairo,
  gdk-pixbuf,
  glib,
  pango,
  harfbuzz,
  gobject-introspection,
  fontconfig,
  freetype,
  libxkbcommon,
  libxcb,
  libglvnd,
  wayland,
  vulkan-loader,
  librsvg,
  libnotify,
  ffmpeg,
  wl-clipboard,
  wtype,
  pulseaudio,
  at-spi2-core,
  python3,
  runCommand,
}:

let
  pname = "superwhisper";
  version = "1.3.1";

  # Upstream publishes a portable per-user bundle (Wayland-only). The author is
  # superultrainc; see https://tux.superwhisper.com/stable.json for releases.
  sources = {
    x86_64-linux = {
      url = "https://tux.superwhisper.com/x86_64/v${version}/superwhisper-omarchy-x86_64-${version}.tar.zst";
      hash = "sha256-RkpzLKbJKNPyuLuUaHF2p1yisJwYYzPTTZTQUcy18OQ=";
    };
    aarch64-linux = {
      url = "https://tux.superwhisper.com/aarch64/v${version}/superwhisper-omarchy-aarch64-${version}.tar.zst";
      hash = "sha256-pEDIXqMb2ww8Oz3pcaBCQCzGmO+ifFTcVzyVU/0o8G8=";
    };
  };

  src = fetchurl (
    sources.${stdenv.hostPlatform.system}
      or (throw "${pname} is not packaged for ${stdenv.hostPlatform.system}")
  );

  # librsvg ships libpixbufloader_svg.so but its own loaders.cache predates the
  # loader, so generate one that lists every loader we install.
  gdkPixbufLoadersCache =
    runCommand "superwhisper-gdk-pixbuf-loaders.cache"
      {
        nativeBuildInputs = [ gdk-pixbuf.dev ];
      }
      ''
        gdk-pixbuf-query-loaders \
          ${gdk-pixbuf}/lib/gdk-pixbuf-2.0/2.10.0/loaders/*.so \
          ${librsvg}/lib/gdk-pixbuf-2.0/2.10.0/loaders/*.so > $out
      '';

  # The daemon shells out to these scripts, which import gi/cairo.
  pythonEnv = python3.withPackages (ps: [
    ps.pygobject3
    ps.pycairo
  ]);

  # Found through PATH by the daemon: notifications, media ducking, the
  # clipboard fallback and wlroots paste-through-wtype.
  runtimeDeps = [
    ffmpeg
    libnotify
    wl-clipboard
    wtype
    pulseaudio
    fontconfig
  ];

  # Loaded with dlopen, so they must be on LD_LIBRARY_PATH rather than RPATH:
  # the recording pill (gtk4-layer-shell), the settings window's Wayland client
  # connection (GPUI) and its GL/Vulkan context.
  dlopenLibs = lib.makeLibraryPath [
    gtk4-layer-shell
    libglvnd
    wayland
    vulkan-loader
    gtk4
    gdk-pixbuf
    graphene
    cairo
    glib
    fontconfig
    libxkbcommon
    libxcb
  ];
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    autoPatchelfHook
    wrapGAppsHook4
    makeWrapper
    zstd
  ];

  buildInputs = [
    gcc.cc.lib # libstdc++, libgomp (workers are C++/OpenMP)
    gtk4
    graphene
    cairo
    gdk-pixbuf
    glib
    pango
    harfbuzz
    fontconfig
    freetype
    libxkbcommon
    libxcb
    libglvnd
    wayland
    vulkan-loader
    gtk4-layer-shell
    at-spi2-core
    librsvg
  ];

  dontConfigure = true;
  dontBuild = true;
  dontWrapGApps = true;
  dontStrip = true;

  # GNU tar in the sandbox cannot always be trusted with --zstd; pipe it.
  unpackPhase = ''
    runHook preUnpack
    mkdir source
    zstd -dc "$src" | tar -xf - -C source --strip-components=1
    cd source
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    install -d $out/share/superwhisper
    cp -a app $out/share/superwhisper/app

    # fcitx5 (input-method commit path) is not used here and would otherwise
    # need fcitx5 as a runtime dependency.
    rm -rf $out/share/superwhisper/app/lib/fcitx5 \
      $out/share/superwhisper/app/assets/fcitx5

    install -d $out/share/doc/superwhisper
    cp -a licenses README.md BUILD_INFO.json $out/share/doc/superwhisper/

    for size in 16 32 64 128 256 512 1024; do
      install -Dm644 "app/assets/app-icon/$size.png" \
        "$out/share/icons/hicolor/''${size}x''${size}/apps/superwhisper.png"
    done

    # Glyph fonts for the recording pill / TUI status.
    install -Dm644 app/assets/linux-status/SuperwhisperStatus.ttf \
      $out/share/fonts/truetype/superwhisper/SuperwhisperStatus.ttf
    install -Dm644 app/assets/linux-status/SuperwhisperTUI.ttf \
      $out/share/fonts/truetype/superwhisper/SuperwhisperTUI.ttf

    chmod -R u+w $out
    runHook postInstall
  '';

  # app/run.sh is fully self-relative (it resolves the bundle from its own
  # path), so the store copy works. updates are impossible from a read-only
  # store: bump `version`/`hash` instead.
  postFixup = ''
    makeWrapper $out/share/superwhisper/app/run.sh $out/bin/superwhisper \
      "''${gappsWrapperArgs[@]}" \
      --prefix PATH : ${lib.makeBinPath runtimeDeps} \
      --prefix PATH : ${pythonEnv}/bin \
      --prefix LD_LIBRARY_PATH : ${dlopenLibs} \
      --prefix GI_TYPELIB_PATH : ${
        lib.makeSearchPathOutput "out" "lib/girepository-1.0" [
          gtk4
          graphene
          gdk-pixbuf
          glib
          pango
          harfbuzz
          gobject-introspection
          at-spi2-core
        ]
      } \
      --set GDK_PIXBUF_MODULE_FILE ${gdkPixbufLoadersCache} \
      --set SUPERWHISPER_UPDATE_DISABLED 1
  '';

  meta = {
    description = "Local and cloud voice-to-text dictation (proprietary Linux build)";
    homepage = "https://superwhisper.com/linux";
    downloadPage = "https://tux.superwhisper.com/stable.json";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "superwhisper";
  };
}
