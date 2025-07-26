{pkgs, ...}: {
  home.persistence = {
    "/persist/home/rajkoh".directories = [".local/share/JetBrains"];
  };

  home.packages = with pkgs; [
    jetbrains-toolbox
  ];
}
