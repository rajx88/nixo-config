{
  lib,
  fetchurl,
  appimageTools,
  writeShellScriptBin,
  symlinkJoin,
}:
let
  pname = "pokebonk";
  version = "1.3.0";

  # Official desktop client, published by the game's author. The download URL is
  # the same one the game itself uses for its in-game "App" button.
  src = fetchurl {
    url = "https://github.com/CharcherGit/pokebonk-app/releases/download/v${version}/PokeBonk-${version}-linux-x86_64.AppImage";
    # sha256 digest from the GitHub release API (assets[].digest)
    hash = "sha256-Zf+CObCXOJBt7YSmOW9l6efNiRaTXMeLkKhVJ3pIgyA=";
  };

  appimageContents = appimageTools.extract { inherit pname version src; };

  appimage = appimageTools.wrapType2 {
    inherit pname version src;

    # The client is an Electron shell that loads https://pokebonk.com, so this is
    # a window around the live game: game updates arrive without a version bump.
    #
    # The bundled .desktop launches with --no-sandbox. Drop it: unprivileged user
    # namespaces work here, and a shell that renders remote content is exactly
    # where the Chromium sandbox earns its keep. X11 (XWayland) is kept as the
    # default backend because the game captures the pointer, which native Wayland
    # still handles worse than XWayland.
    extraInstallCommands = ''
      install -Dm444 ${appimageContents}/usr/share/icons/hicolor/512x512/apps/PokeBonk.png \
        $out/share/icons/hicolor/512x512/apps/PokeBonk.png

      install -Dm444 ${appimageContents}/pokebonk.desktop \
        $out/share/applications/pokebonk.desktop
      substituteInPlace $out/share/applications/pokebonk.desktop \
        --replace-fail 'Exec=AppRun --no-sandbox %U' 'Exec=pokebonk %U'
    '';

    meta = {
      description = "Desktop client for PokéBonk, an unofficial 3D Pokémon survivor fan game";
      homepage = "https://pokebonk.com";
      changelog = "https://github.com/CharcherGit/pokebonk-app/releases/tag/v${version}";
      # Upstream declares the package UNLICENSED; only the binary is distributed.
      license = lib.licenses.unfree;
      sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
      platforms = [ "x86_64-linux" ];
    };
  };

  # Upstream's productName is "PokéBonk", so Electron's userData — the login
  # cookies and the game saves in localStorage — defaults to ~/.config/PokéBonk.
  # A non-ASCII directory cannot survive impermanence: the bind-mount unit name
  # is derived from the path, and systemd only loads escaped unit filenames, so
  # `home-rajx88-.config-PokéBonk.mount` is silently never mounted and the data
  # lands on the ephemeral root. Point the profile at an ASCII path, which also
  # makes the unit name `home-rajx88-.config-pokebonk.mount`.
  wrapper = writeShellScriptBin pname ''
    exec ${lib.getExe' appimage pname} \
      --user-data-dir="''${XDG_CONFIG_HOME:-$HOME/.config}/${pname}" "$@"
  '';
in
symlinkJoin {
  name = "${pname}-${version}";

  paths = [ appimage ];

  postBuild = ''
    rm $out/bin/${pname}
    ln -s ${lib.getExe' wrapper pname} $out/bin/${pname}
  '';

  meta = appimage.meta // {
    mainProgram = pname;
  };
}
