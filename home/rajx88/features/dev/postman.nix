{pkgs, ...}: {
  home.packages = with pkgs; [
    postman
  ];

  home.persistence."/persist".directories = [".config/Postman"];
}
