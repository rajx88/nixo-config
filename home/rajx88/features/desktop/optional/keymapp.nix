{pkgs, ...}: {
  home.packages = with pkgs; [
    keymapp
  ];

  home.persistence = {
    "/persist/home/rajx88".directories = [
      ".config/.keymapp"
      ".local/share/keymapp"
    ];
  };
}
