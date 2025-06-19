{pkgs, ...}: {
  home.packages = with pkgs; [
    signal-desktop
  ];

  home.persistence = {
    "/persist/home/rajkoh".directories = [
      ".config/Signal"
    ];
  };
}
