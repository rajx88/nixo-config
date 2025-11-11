{pkgs, ...}: {
  home.persistence."/persist".directories = [".local/share/JetBrains"];

  home.packages = with pkgs; [
    jetbrains-toolbox
  ];
}
