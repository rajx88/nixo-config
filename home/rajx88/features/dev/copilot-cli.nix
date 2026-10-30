{ pkgs, ... }: {
  home.packages = [ pkgs.copilot-cli ];

  home.persistence."/persist".directories = [
    ".copilot" # auth, sessions, memories
  ];
}
