{pkgs, ...}: {
  home.packages = with pkgs; [
    spotify
  ];

  home.persistence = {
    "/persist/home/rajkoh".directories = [".config/spotify"];
  };
}
