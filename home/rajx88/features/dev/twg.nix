{ pkgs, ... }: {
  home.packages = [ pkgs.twg ];

  # ~/.config/twg holds auth.conf (OAuth access/refresh tokens), upkeep.json and
  # any installer-owned agent skills. Off the ephemeral root they are wiped every
  # boot, which would force a full `twg login` browser consent on every start.
  home.persistence."/persist".directories = [
    ".config/twg"
  ];
}
