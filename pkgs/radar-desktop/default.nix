{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  wrapGAppsHook3,
  gtk3,
  glib,
  gdk-pixbuf,
  webkitgtk_4_1,
  libsoup_3,
  makeDesktopItem,
  copyDesktopItems,
}:
let
  version = "1.8.1";
  desktopItem = makeDesktopItem {
    name = "radar-desktop";
    exec = "radar-desktop";
    icon = "radar-desktop";
    desktopName = "Radar";
    comment = "Modern Kubernetes visibility — topology, traffic, and Helm management";
    categories = [ "Development" "Network" ];
  };
in
stdenv.mkDerivation {
  pname = "radar-desktop";
  inherit version;

  src = fetchurl {
    url = "https://github.com/skyhook-io/radar/releases/download/v${version}/radar-desktop_v${version}_linux_amd64.tar.gz";
    hash = "sha256-Bi/I+cnhSC4vLNlGGkhJxbW/E4dLwemo7bPu+qYM+ec=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
    wrapGAppsHook3
    copyDesktopItems
  ];

  buildInputs = [
    glib
    gtk3
    gdk-pixbuf
    webkitgtk_4_1
    libsoup_3
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 radar-desktop $out/bin/radar-desktop
    runHook postInstall
  '';

  desktopItems = [ desktopItem ];

  meta = {
    description = "Modern Kubernetes visibility — topology, traffic, and Helm management (desktop app)";
    homepage = "https://radarhq.io";
    license = lib.licenses.asl20;
    mainProgram = "radar-desktop";
    platforms = [ "x86_64-linux" ];
  };
}
