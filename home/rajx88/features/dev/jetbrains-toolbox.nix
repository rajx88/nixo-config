{pkgs, ...}: {
  home.persistence = {
    "/persist/home/rajx88".directories = [".local/share/JetBrains"];
  };

  home.packages = with pkgs; [
    jetbrains-toolbox
  ];
}
