{pkgs, ...}: {
  # Persist JetBrains IDE settings and metadata across reboots with impermanence.
  home.persistence = {
    "/persist/home/rajx88".directories = [
      ".local/share/JetBrains"
      ".config/JetBrains"
    ];
  };

  home.packages = with pkgs; [
    jetbrains.idea-ultimate
  ];
}
