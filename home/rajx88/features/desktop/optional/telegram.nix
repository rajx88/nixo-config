{ pkgs, ... }: {
  home.packages = with pkgs; [
    telegram-desktop
  ];

  # Telegram Desktop keeps its session/data here; persist it so the login
  # survives reboots on impermanence hosts.
  home.persistence."/persist".directories = [
    ".local/share/TelegramDesktop"
  ];
}
