{
  lib,
  fetchurl,
  appimageTools,
}:
let
  pname = "bruno";
  version = "4.3.0";

  src = fetchurl {
    url = "https://github.com/usebruno/bruno/releases/download/v${version}/bruno_${version}_x86_64_linux.AppImage";
    # sha256 digest from the GitHub release API (assets[].digest)
    hash = "sha256-PDhrEAf2bYdcNKKlAgY/utZcZuN0CaMW6+UYeIsegLs=";
  };

  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  # Wayland: let Electron pick ozone backend from the session.
  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/bruno.desktop $out/share/applications/bruno.desktop
    cp -r ${appimageContents}/usr/share/icons $out/share/icons
    substituteInPlace $out/share/applications/bruno.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=bruno --ozone-platform-hint=auto --enable-wayland-ime' \
      --replace-quiet 'Exec=bruno %U' 'Exec=bruno --ozone-platform-hint=auto --enable-wayland-ime %U'
  '';

  meta = {
    description = "Open-source API client (Postman/Insomnia alternative)";
    homepage = "https://www.usebruno.com";
    changelog = "https://github.com/usebruno/bruno/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "bruno";
    platforms = [ "x86_64-linux" ];
  };
}
