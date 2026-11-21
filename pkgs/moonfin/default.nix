{
  lib,
  fetchurl,
  appimageTools,
}:
let
  pname = "moonfin";
  version = "3.1.1";

  src = fetchurl {
    url = "https://github.com/Moonfin-Client/Moonfin-Core/releases/download/${version}/Moonfin_Linux_v${version}.AppImage";
    # sha256 digest from the GitHub release API (assets[].digest)
    hash = "sha256-B8yr0eDmJuizzjKuqwZ92cE0aFWwQB4HynMs6pM08tc=";
  };

  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  # The image expects these from the host (its AppRun ldd check lists them);
  # gtk3 does not pull libepoxy into the FHS profile on its own.
  extraPkgs =
    pkgs: with pkgs; [
      libepoxy
      libXv
    ];

  # The image already ships an entry whose Exec is `moonfin %U`, which is the
  # binary wrapType2 installs, so only the entry and the themed icon need to be
  # copied into the profile. The FHS wrapper supplies GTK, X11/Wayland and GL;
  # the image carries its own libmpv and WebKitGTK.
  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/org.moonfin.linux.desktop \
      $out/share/applications/org.moonfin.linux.desktop
    cp -r ${appimageContents}/usr/share/icons $out/share/icons
  '';

  meta = {
    description = "Media client for self-hosted media servers (Jellyfin, Emby, Plex, Silo)";
    homepage = "https://moonfin.io";
    changelog = "https://github.com/Moonfin-Client/Moonfin-Core/releases/tag/${version}";
    license = lib.licenses.gpl3Plus;
    mainProgram = "moonfin";
    platforms = [ "x86_64-linux" ];
  };
}
