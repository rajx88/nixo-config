{pkgs, ...}: {
  home.packages = with pkgs; [
    keymapp
  ];

  home.persistence."/persist".directories = [
    ".config/.keymapp"
    ".local/share/keymapp"
  ];
}
