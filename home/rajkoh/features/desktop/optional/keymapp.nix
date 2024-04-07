{pkgs, ...}: {
  home.packages = with pkgs; [
    keymapp
  ];

  home.persistence = {
    "/persist/home/rajkoh".directories = [
      ".config/.keymapp"
      ".local/share/keymapp"
    ];
  };
}
