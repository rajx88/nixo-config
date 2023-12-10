{ inputs, outputs, ... }: {
  imports = [
    ./global

    ./features/desktop/gnome
  ];
  
  xdg.enable = true;

}
