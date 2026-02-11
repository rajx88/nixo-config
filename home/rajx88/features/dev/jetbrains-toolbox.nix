{pkgs, ...}: {
  home.persistence."/persist" = {
    directories = [
      ".local/share/JetBrains"
      ".config/JetBrains"
      ".config/github-copilot" # Copilot plugin settings
      ".java/.userPrefs" # Java intellij settings
    ];
  };

  home.packages = with pkgs; [
    jetbrains-toolbox
  ];
}
