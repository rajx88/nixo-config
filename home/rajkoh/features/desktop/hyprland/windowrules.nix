{
  wayland.windowManager.hyprland.settings = {
    windowrulev2 = [
      "float, class:^ (leagueclientux.exe)$,title:^ (League of Legends)$"
      "size 2560 1440,class:^ (league of legends.exe)$"
      "fullscreen,class:^ (league of legends.exe)$"
      "nofullscreenrequest, class:^(cs2)$"
      "nomaximizerequest, class:^(cs2)$"
    ];

    windowrule = [
      "size 1280 720,^ (leagueclientux.exe)$"
      "center,^ (leagueclientux.exe)$"
    ];
  };
}
