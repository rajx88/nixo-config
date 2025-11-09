{pkgs, ...}: {
  home.packages = with pkgs; [
    spotify
  ];

  home.persistence = {
    "/persist/home/rajx88".directories = [".config/spotify"];
  };
}
