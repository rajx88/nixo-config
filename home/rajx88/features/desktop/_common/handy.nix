{
  pkgs,
  config,
  lib,
  ...
}:
let
  # Handy has no settings CLI: it keeps everything in an app-owned JSON store
  # (settings_store.json) that the GUI writes. Only the two values that make it
  # work on Wayland are pinned; everything else (translation, language, overlay,
  # feedback, retention, vocabulary) is Handy's own setting, owned by the GUI.
  # The app merges these over its defaults and keeps later GUI edits.
  # The model is not seeded: a fresh install gets Handy's first-run wizard,
  # which downloads/selects one (large-v3 is ~1.7 GB, not an activation job).
  settings = {
    settings_schema_version = 2;
    # wtype types the text instead of sending a paste chord, so this works in
    # terminals and Wayland-native apps without focus/app detection. The tool
    # itself must be first in Handy's list; enigo is X11-only.
    paste_method = "direct";
    typing_tool = "wtype";
    # Handy's own retention (never/preserve_limit/days3/weeks2/months3); keep
    # its audio clips for two weeks, then Handy prunes them itself.
    recording_retention_period = "weeks2";
  };
in
{
  home.packages = [
    pkgs.handy

    # Handy inserts text through the first tool it finds: on Wayland that is
    # wtype, then dotool/ydotool, then enigo (X11). Without any of them it fell
    # back to enigo, which cannot type into Wayland-native windows such as
    # ghostty. dotool would need the input group; wtype is the one that works.
    pkgs.wtype

    # Clipboard fallback: if the paste method is ever switched to
    # clipboard/Ctrl+V, Handy shells out to wl-copy/wl-paste.
    pkgs.wl-clipboard
  ];

  # Models, history.db, recordings and the transcription hook. The models are
  # large (Whisper large-v3 ~1.7 GB, Parakeet ~730 MB) and downloaded at
  # runtime.
  home.persistence."/persist".directories = [
    ".local/share/com.pais.handy"
    ".config/com.pais.handy"
  ];

  # Handy's own autostart toggle writes ~/.config/autostart, which needs
  # xdg-desktop-autostart.target and persistence to work here, so the mango
  # autostart script launches it instead (see mango/default.nix).

  # Seed the store only when it does not exist yet (fresh install); after that
  # the GUI owns the file.
  home.activation.handySettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    store="${config.home.homeDirectory}/.local/share/com.pais.handy/settings_store.json"
    if [ ! -e "$store" ]; then
      verboseEcho "Seeding Handy settings"
      mkdir -p "$(dirname "$store")"
      printf '%s\n' '${builtins.toJSON { settings = settings; }}' > "$store"
      chmod 600 "$store"
    fi
  '';
}
