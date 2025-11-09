{pkgs, ...}: {
  home.packages = with pkgs; [
    ferdium
  ];

  home.persistence = {
    "/persist/home/rajx88".directories = [
      ".config/Ferdium"
    ];
  };
}
