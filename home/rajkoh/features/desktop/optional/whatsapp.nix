{pkgs, ...}: {
  home.packages = with pkgs; [
    whatsapp-for-linux
  ];

  home.persistence = {
    "/persist/home/rajkoh".directories = [".local/share/whatsapp-for-linux"];
  };
}
