{
  lib,
  stdenv,
  fetchurl,
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
  gtk3,
  libdrm,
  libx11,
  libxkbcommon,
  libxscrnsaver,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxrandr,
  libxrender,
  libxshmfence,
  libxtst,
  libuuid,
  libgbm,
  nspr,
  nss,
  pango,
  pipewire,
  udev,
  wayland,
  libxcb,
  zlib,
  libkrb5,
  libxkbfile,
  libGL,
  libpulseaudio,
  glib-networking,
}:

let
  pname = "cursor";
  version = "3.15.19";

  src = fetchurl {
    url = "https://downloads.cursor.com/production/de07bee81cefe43461ebf4f40c3d2d78d15052aa/linux/x64/deb/amd64/deb/cursor_3.15.19_amd64.deb";
    hash = "sha256-9ywKf58Q0h072gaoipHChphviGYr9kGD2oVioKbDFJI=";
  };

  deps = [
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
    libgbm
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

  rpath = lib.makeLibraryPath deps + ":" + lib.makeSearchPathOutput "lib" "lib64" deps;
in
stdenv.mkDerivation {
  inherit pname version src;

  dontConfigure = true;
  dontBuild = true;
  dontPatchELF = true;
  dontStrip = true;
  doInstallCheck = true;

  nativeBuildInputs = [ makeWrapper ];

  unpackPhase = ''
    ar x $src
    tar xf data.tar.xz --no-same-permissions
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share
    cp -r usr/share/cursor $out/share/cursor
    cp -r usr/share/applications $out/share/applications
    cp -r usr/share/pixmaps $out/share/pixmaps
    cp -r usr/share/bash-completion $out/share/bash-completion
    cp -r usr/share/mime $out/share/mime
    cp -r usr/share/appdata $out/share/appdata

    chmod 755 $out/share/cursor/chrome-sandbox

    # CLI entry point
    ln -s $out/share/cursor/bin/cursor $out/bin/cursor

    # Patchelf all ELF binaries (include bundled libs path for libffmpeg.so etc.)
    for exe in $out/share/cursor/{cursor,chrome_crashpad_handler,chrome-sandbox}; do
      patchelf \
        --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --set-rpath "${rpath}:$out/share/cursor" $exe
    done

    for exe in $out/share/cursor/bin/{code-tunnel,cursor-tunnel}; do
      if [ -f "$exe" ]; then
        patchelf \
          --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
          --set-rpath "${rpath}:$out/share/cursor" $exe || true
      fi
    done

    # Remove musl-linked binaries (incompatible with glibc)
    find $out -name "*linux-x64-musl*" -delete 2>/dev/null || true

    # Fix desktop file paths and add --no-sandbox (no setuid chrome-sandbox in Nix)
    substituteInPlace $out/share/applications/cursor.desktop \
        --replace-fail "/usr/share/cursor/cursor %F" "$out/share/cursor/cursor --no-sandbox %F"

    substituteInPlace $out/share/applications/cursor-url-handler.desktop \
        --replace-fail "/usr/share/cursor/cursor" "$out/share/cursor/cursor --no-sandbox"

    runHook postInstall
  '';

  installCheckPhase = ''
    $out/bin/cursor --version >/dev/null 2>&1 || true
  '';

  meta = {
    homepage = "https://cursor.com";
    description = "AI-first code editor built on VSCode";
    license = lib.licenses.unfree;
    platforms = ["x86_64-linux"];
    mainProgram = "cursor";
  };
}
