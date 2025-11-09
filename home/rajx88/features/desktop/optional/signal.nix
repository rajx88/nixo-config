{pkgs, ...}: {
  home.packages = with pkgs; [
    signal-desktop
  ];

  home.persistence = {
    "/persist/home/rajx88".directories = [
      ".config/Signal"
    ];
  };
}
