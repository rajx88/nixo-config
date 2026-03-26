{pkgs, ...}: {
  home.persistence."/persist".directories = [
    ".local/share/rtk"
  ];

  home.packages = with pkgs; [
    rtk
  ];
}
