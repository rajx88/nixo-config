{ pkgs, ... }: {
  # org.moonfin.linux is the native build's GTK application id, so Flutter's
  # path_provider puts preferences and the default download folder under it.
  # Persist it or settings vanish on every boot. The offline catalogue lives in
  # ~/Documents/Moonfin, which global persistence already covers.
  home.persistence."/persist".directories = [
    ".local/share/org.moonfin.linux"
  ];

  home.packages = with pkgs; [
    moonfin
  ];
}
