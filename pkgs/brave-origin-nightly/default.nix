{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
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
  adwaita-icon-theme,
  gsettings-desktop-schemas,
  gtk3,
  gtk4,
  qt6,
  libx11,
  libxscrnsaver,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxrandr,
  libxrender,
  libxtst,
  libdrm,
  libkrb5,
  libuuid,
  libxkbcommon,
  libxshmfence,
  libgbm,
  nspr,
  nss,
  pango,
  pipewire,
  snappy,
  udev,
  wayland,
  xdg-utils,
  coreutils,
  libxcb,
  zlib,
  makeWrapper,
  commandLineArgs ? "",
  pulseSupport ? true,
  libpulseaudio,
  libGL,
  libvaSupport ? true,
  libva,
  enableVideoAcceleration ? libvaSupport,
  vulkanSupport ? false,
  addDriverRunpath,
  enableVulkan ? vulkanSupport,
}:

let
  pname = "brave-origin-nightly";
  version = "1.92.99";

  src = fetchurl {
    url = "https://github.com/brave/brave-browser/releases/download/v${version}/brave-origin-nightly_${version}_amd64.deb";
    hash = "sha256-hJM4lDWNMhxM8Wi97OYFY8xI5gNVkfVFSiN3Yd0AqVM=";
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
    gtk3
    gtk4
    libdrm
    libx11
    libGL
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
    snappy
    libkrb5
    qt6.qtbase
  ]
  ++ lib.optional pulseSupport libpulseaudio
  ++ lib.optional libvaSupport libva;

  rpath = lib.makeLibraryPath deps + ":" + lib.makeSearchPathOutput "lib" "lib64" deps;
  binpath = lib.makeBinPath deps;

  enableFeatures =
    lib.optionals enableVideoAcceleration [
      "AcceleratedVideoDecodeLinuxGL"
      "AcceleratedVideoEncoder"
    ]
    ++ lib.optional enableVulkan "Vulkan";

  disableFeatures = [
    "OutdatedBuildDetector"
  ]
  ++ lib.optionals enableVideoAcceleration ["UseChromeOSDirectVideoDecoder"];

in
stdenv.mkDerivation {
  inherit pname version src;

  dontConfigure = true;
  dontBuild = true;
  dontPatchELF = true;
  doInstallCheck = true;

  nativeBuildInputs = [
    (buildPackages.wrapGAppsHook3.override { makeWrapper = buildPackages.makeShellWrapper; })
  ];

  buildInputs = [
    glib
    gsettings-desktop-schemas
    gtk3
    gtk4
    adwaita-icon-theme
  ];

  unpackPhase = ''
    ar x $src
    tar xf data.tar.xz --no-same-permissions
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out $out/bin

    cp -R usr/share $out
    cp -R opt/ $out/opt

    export BINARYWRAPPER=$out/opt/brave.com/brave-origin-nightly/brave-origin-nightly

    # Fix path to bash in wrapper
    substituteInPlace $BINARYWRAPPER \
        --replace-fail /bin/bash ${stdenv.shell} \
        --replace-fail 'CHROME_WRAPPER' 'WRAPPER'

    ln -sf $BINARYWRAPPER $out/bin/${pname}

    for exe in $out/opt/brave.com/brave-origin-nightly/{brave,chrome_crashpad_handler}; do
        patchelf \
            --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
            --set-rpath "${rpath}" $exe
    done

    # Fix paths in desktop files
    substituteInPlace $out/share/applications/brave-origin-nightly.desktop \
        --replace-fail /usr/bin/brave-origin-nightly $out/bin/${pname}
    substituteInPlace $out/share/applications/com.brave.Origin.nightly.desktop \
        --replace-fail /usr/bin/brave-origin-nightly $out/bin/${pname}
    substituteInPlace $out/share/gnome-control-center/default-apps/brave-origin-nightly.xml \
        --replace-fail /opt/brave.com $out/opt/brave.com
    substituteInPlace $out/opt/brave.com/brave-origin-nightly/default-app-block \
        --replace-fail /opt/brave.com $out/opt/brave.com

    # Correct icons location
    icon_sizes=("16" "24" "32" "48" "64" "128" "256")

    for icon in ''${icon_sizes[*]}
    do
        mkdir -p $out/share/icons/hicolor/''${icon}x''${icon}/apps
        ln -s $out/opt/brave.com/brave-origin-nightly/product_logo_''${icon}_nightly.png \
          $out/share/icons/hicolor/''${icon}x''${icon}/apps/brave-origin-nightly.png
    done

    # Replace xdg-settings and xdg-mime
    ln -sf ${xdg-utils}/bin/xdg-settings $out/opt/brave.com/brave-origin-nightly/xdg-settings
    ln -sf ${xdg-utils}/bin/xdg-mime $out/opt/brave.com/brave-origin-nightly/xdg-mime

    runHook postInstall
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : ${rpath}
      --prefix PATH : ${binpath}
      --suffix PATH : ${lib.makeBinPath [xdg-utils coreutils]}
      --set CHROME_WRAPPER ${pname}
      ${lib.optionalString (enableFeatures != []) ''
        --add-flags "--enable-features=${lib.strings.concatStringsSep "," enableFeatures}\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+,WaylandWindowDecorations --enable-wayland-ime=true}}"
      ''}
      ${lib.optionalString (disableFeatures != []) ''
        --add-flags "--disable-features=${lib.strings.concatStringsSep "," disableFeatures}"
      ''}
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto}}"
      ${lib.optionalString vulkanSupport ''
        --prefix XDG_DATA_DIRS  : "${addDriverRunpath.driverLink}/share"
      ''}
      ${lib.optionalString (commandLineArgs != "") ''
        --add-flags ${lib.escapeShellArg commandLineArgs}
      ''}
    )
  '';

  installCheckPhase = ''
    $out/opt/brave.com/brave-origin-nightly/brave --version
  '';

  meta = {
    homepage = "https://brave.com/";
    description = "Brave Origin (nightly) - Brave without crypto/web3 features";
    changelog = "https://github.com/brave/brave-browser/blob/master/CHANGELOG_DESKTOP_ORIGIN.md";
    license = lib.licenses.mpl20;
    platforms = ["x86_64-linux"];
    mainProgram = "brave-origin-nightly";
  };
}
