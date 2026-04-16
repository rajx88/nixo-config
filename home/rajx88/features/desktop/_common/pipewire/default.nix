{
  pkgs,
  lib,
  ...
}: {
  home.persistence."/persist" = {
    directories = [
      ".local/state/wireplumber"
      ".config/wireplumber"
    ];
  };
}
