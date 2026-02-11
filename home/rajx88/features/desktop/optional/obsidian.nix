{pkgs, ...}: {
  home.persistence."/persist".directories = [
    ".config/obsidian"
  ];

  home.packages = with pkgs; [
    obsidian
  ];
}
