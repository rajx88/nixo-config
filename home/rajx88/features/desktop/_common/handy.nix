{
  pkgs,
  config,
  lib,
  ...
}:
let
  handy = "${pkgs.handy}/bin/handy";

  prune = pkgs.writeShellScript "handy-prune-recordings" ''
    set -eu
    data="''${XDG_DATA_HOME:-$HOME/.local/share}/com.pais.handy"
    db="$data/history.db"
    dir="$data/recordings"
    [ -f "$db" ] || exit 0
    cutoff=$(( $(${pkgs.coreutils}/bin/date +%s) - 7 * 86400 ))
    ${pkgs.sqlite}/bin/sqlite3 -cmd '.timeout 5000' -separator '|' "$db" \
      "select id, file_name from transcription_history where timestamp < $cutoff" |
      while IFS='|' read -r id file; do
        [ -n "''${file:-}" ] && ${pkgs.coreutils}/bin/rm -f "$dir/$file"
        ${pkgs.sqlite}/bin/sqlite3 -cmd '.timeout 5000' "$db" \
          "delete from transcription_history where id = $id"
      done
    # Clips whose history row is already gone.
    ${pkgs.findutils}/bin/find "$dir" -type f -name '*.wav' -mtime +7 -delete 2>/dev/null || true
  '';

  # Handy has no settings CLI: it keeps everything in an app-owned JSON store
  # (settings_store.json) that the GUI writes. These are the values worth
  # pinning; the app merges them over its own defaults and keeps GUI edits
  # afterwards, so this only seeds a fresh install and never fights the UI.
  # The model is not seeded: a fresh install gets Handy's first-run wizard,
  # which downloads/selects one (large-v3 is ~1.7 GB, not an activation job).
  settings = {
    settings_schema_version = 2;
    selected_language = "auto";
    # Whisper's translate task: Dutch (or any non-English) speech comes out as
    # English. Only models with translate capability honour it.
    translate_to_english = true;
    # wtype types the text instead of sending a paste chord, so this works in
    # terminals and Wayland-native apps without focus/app detection.
    paste_method = "direct";
    clipboard_handling = "dont_modify";
    # The overlay can steal focus on wlroots compositors, which would break
    # pasting; keep it to the small pill at the bottom instead of the live
    # waveform, and leave the chimes off.
    overlay_style = "minimal";
    overlay_position = "bottom";
    autostart_enabled = false; # systemd unit below owns startup
    # The start/stop chimes are surprising on a laptop and overlap when a key
    # is held; the recording overlay is off for focus reasons, so the tray
    # icon and the text appearing are the feedback. Flip this to true in the
    # GUI if you want the cues.
    audio_feedback = false;
    # Handy always keeps the 16 kHz WAV of every dictation next to the history
    # entry (32 KB/s) and 0.9.8 has no "text only" switch. Its own retention
    # only offers 3 days, 2 weeks or 3 months, so keep 2 weeks as a backstop and
    # prune at 7 days with the timer below.
    recording_retention_period = "weeks2";
    # Only used if the retention period is switched back to the count-based
    # "preserve_limit"; the default of 5 would prune almost everything.
    history_limit = 500;
    # wtype is the only tool that can inject text into Wayland-native windows
    # here; auto-fallback otherwise picks enigo, which is X11-only.
    typing_tool = "wtype";
    custom_words = [
      "akarnae"
      "nixos"
      "netbird"
      "ghostty"
      "mangowm"
      "nixo-config"
    ];
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

  # Handy has its own autostart toggle, but that writes ~/.config/autostart,
  # which is not persisted here. Keep the startup declarative instead.
  systemd.user.services.handy = {
    Unit = {
      Description = "Handy speech-to-text";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${handy} --start-hidden";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

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

  # Trim exactly seven days. Handy's own retention cannot express it: the enum
  # only has 3 days, 2 weeks and 3 months. Entries older than the cutoff lose
  # their WAV and their history row together, which is the coupling Handy uses
  # itself when it prunes.
  systemd.user.services.handy-prune = {
    Unit.Description = "Drop Handy history entries and recordings older than 7 days";
    Service = {
      Type = "oneshot";
      ExecStart = "${prune}";
    };
  };

  systemd.user.timers.handy-prune = {
    Unit.Description = "Daily Handy recording retention";
    Timer = {
      OnCalendar = "daily";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
