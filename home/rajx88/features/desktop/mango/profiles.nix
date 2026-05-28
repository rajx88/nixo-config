{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.monitorProfiles;

  profileNames = builtins.attrNames cfg.profiles;

  wsToKey = ws: if ws == 10 then "0" else toString ws;

  # Generate a config snippet for a given profile
  mkProfileSnippet = name: profile: let
    enabledMonitors = lib.filter (m: m.enabled) profile.monitors;

    # Compute logical dimensions for a monitor
    logicalW = m: m.width / m.scale;
    logicalH = m: m.height / m.scale;

    # Compute positions for all monitors.
    # First monitor is always at 0,0.
    # Subsequent monitors use directional placement relative to previous:
    #   "auto" / "auto-right" → right of previous
    #   "auto-left"           → left of previous
    #   "auto-above"          → above previous
    #   "auto-below"          → below previous
    #   "center-below"        → centered below previous
    #   "center-above"        → centered above previous
    #   "NxN"                 → explicit logical coordinates
    computePositions = let
      step = acc: m: let
        prev = if acc == [] then { x = 0; y = 0; w = 0; h = 0; } else lib.last acc;
        thisW = logicalW m;
        thisH = logicalH m;
        pos =
          if acc == [] then
            (if m.position != "auto" && !lib.hasPrefix "auto-" m.position && !lib.hasPrefix "center-" m.position
            then let parts = lib.splitString "x" m.position; in { x = lib.toInt (builtins.elemAt parts 0); y = lib.toInt (builtins.elemAt parts 1); }
            else { x = 0; y = 0; })  # first monitor defaults to 0,0 unless explicit
          else if m.position == "auto" || m.position == "auto-right" then
            { x = prev.x + prev.w; y = prev.y; }
          else if m.position == "auto-left" then
            { x = prev.x - thisW; y = prev.y; }
          else if m.position == "auto-above" then
            { x = prev.x; y = prev.y - thisH; }
          else if m.position == "auto-below" then
            { x = prev.x; y = prev.y + prev.h; }
          else if m.position == "center-below" then
            { x = prev.x + (prev.w - thisW) / 2.0; y = prev.y + prev.h; }
          else if m.position == "center-above" then
            { x = prev.x + (prev.w - thisW) / 2.0; y = prev.y - thisH; }
          else let
            parts = lib.splitString "x" m.position;
          in { x = lib.toInt (builtins.elemAt parts 0); y = lib.toInt (builtins.elemAt parts 1); };
      in acc ++ [{ inherit (pos) x y; w = thisW; h = thisH; }];
    in lib.foldl' step [] enabledMonitors;

    positions = computePositions;

    # monitorrule lines
    monitorrules = lib.imap0 (idx: m: let
      pos = builtins.elemAt positions idx;
      posStr = ",x:${toString (builtins.floor pos.x)},y:${toString (builtins.floor pos.y)}";
    in "monitorrule = name:^${m.name}$,width:${toString m.width},height:${toString m.height},refresh:${toString m.refreshRate}${posStr},scale:${toString m.scale}" + (lib.optionalString (m.vertical != "0") ",rr:${m.vertical}")
    ) enabledMonitors;

    # workspace bind lines
    wsBinds = lib.concatMap (m:
      map (ws: "bind = SUPER,${wsToKey ws},viewcrossmon,${toString ws},^${m.name}$") m.workspaces
      ++ map (ws: "bind = SUPER+SHIFT,${wsToKey ws},tagcrossmon,${toString ws},^${m.name}$") m.workspaces
    ) (lib.filter (m: m.workspaces != []) enabledMonitors);

    # tagrule lines
    tagrules = lib.concatMap (m:
      map (ws: "tagrule = id:${toString ws},layout_name:${m.layout}") m.workspaces
    ) (lib.filter (m: m.workspaces != [] && m.layout != "") enabledMonitors);

  in builtins.concatStringsSep "\n" (monitorrules ++ wsBinds ++ tagrules);

  # Write snippet files
  snippetFiles = lib.mapAttrs' (name: profile:
    lib.nameValuePair "mango/profiles/${name}.conf" {
      text = mkProfileSnippet name profile;
    }
  ) cfg.profiles;

  # Menu script (fuzzel dmenu picker)
  mprofileMenuScript = pkgs.writeShellScriptBin "mprofile-menu" ''
    set -euo pipefail
    choice=$(mprofile list | ${pkgs.fuzzel}/bin/fuzzel --dmenu \
      --prompt "Monitor Profile: " \
      --lines=${toString (builtins.length profileNames)} \
      --width=20 \
      --inner-pad=12 \
      --line-height=24 \
      --background=1a1b26d9 \
      --text-color=c0caf5ff \
      --match-color=7aa2f7ff \
      --selection-color=283457d9 \
      --selection-text-color=c0caf5ff \
      --border-color=7aa2f7ff \
      --border-width=2 \
      --border-radius=8)
    [ -n "$choice" ] && mprofile set "$choice"
  '';

  # Monitor profile switcher script
  monitorProfileScript = pkgs.writeShellScriptBin "mprofile" ''
    set -euo pipefail
    CONF_DIR="''${XDG_CONFIG_HOME:-$HOME/.config}/mango"
    PROFILES_DIR="$CONF_DIR/profiles"
    ACTIVE="$CONF_DIR/active-profile.conf"

    WLR_RANDR="${pkgs.wlr-randr}/bin/wlr-randr"
    JQ="${pkgs.jq}/bin/jq"

    list_profiles() {
      printf '%s\n' ${lib.escapeShellArgs profileNames}
    }

    apply_profile() {
      local profile="$1"
      if [ ! -f "$PROFILES_DIR/$profile.conf" ]; then
        echo "Unknown profile: $profile" >&2
        exit 1
      fi

      ln -sf "profiles/$profile.conf" "$ACTIVE"
      mmsg dispatch reload_config
    }

    auto_detect() {
      local randr_output
      randr_output="$($WLR_RANDR --json)"

      local external_count
      external_count=$(echo "$randr_output" | $JQ '[.[] | select(.name | startswith("eDP") | not) | select(.enabled)] | length')

      local external_modes
      external_modes=$(echo "$randr_output" | $JQ -r '[.[] | select(.name | startswith("eDP") | not) | select(.enabled) | .modes[] | select(.current) | "\(.width)x\(.height)@\(.refresh | round)"] | .[]')

      ${builtins.concatStringsSep "\n" (map (name: let
        profile = cfg.profiles.${name};
        countCheck = if profile.detect.externalCount != null
          then "[ \"$external_count\" = \"${toString profile.detect.externalCount}\" ]"
          else "true";
        resChecks = map (r: "echo \"$external_modes\" | grep -qF \"${r}\"") profile.detect.resolutions;
        allChecks = builtins.concatStringsSep " && " ([countCheck] ++ resChecks);
      in ''
        if ${allChecks}; then
          apply_profile "${name}"
          exit 0
        fi
      '') profileNames)}

      # Fallback to default
      apply_profile "${cfg.default}"
    }

    case "''${1:-}" in
      list) list_profiles ;;
      auto) auto_detect ;;
      set)
        if [ -z "''${2:-}" ]; then
          echo "Usage: mprofile set <PROFILE>" >&2
          echo "Available: $(list_profiles | tr '\n' ' ')" >&2
          exit 1
        fi
        apply_profile "$2"
        ;;
      "")
        echo "Usage: mprofile <command>" >&2
        echo "" >&2
        echo "Commands:" >&2
        echo "  list          List available profile names" >&2
        echo "  auto          Auto-detect and apply profile" >&2
        echo "  set <PROFILE> Apply a named profile" >&2
        exit 1
        ;;
      *) echo "Unknown command: $1" >&2; exit 1 ;;
    esac
  '';


in lib.mkIf (cfg.enable or false) {
  xdg.configFile = snippetFiles;

  home.packages = [
    monitorProfileScript
    mprofileMenuScript
    pkgs.fuzzel
    pkgs.jq
    pkgs.wlr-randr
  ];

  home.file.".local/completions/_mprofile".text = ''
    #compdef mprofile

    _mprofile() {
      local -a commands
      commands=(
        'list:List available profile names'
        'auto:Auto-detect and apply profile'
        'set:Apply a named profile'
      )

      if (( CURRENT == 2 )); then
        _describe -t commands 'mprofile command' commands
      elif (( CURRENT == 3 )) && [[ "$words[2]" == "set" ]]; then
        local -a profiles
        profiles=(''${(f)"$(mprofile list 2>/dev/null)"})
        _describe -t profiles 'profile name' profiles
      fi
    }

    _mprofile "$@"
  '';

  programs.fish.completions.mprofile = ''
    complete -c mprofile -f
    complete -c mprofile -n "__fish_use_subcommand" -a list -d "List available profile names"
    complete -c mprofile -n "__fish_use_subcommand" -a auto -d "Auto-detect and apply profile"
    complete -c mprofile -n "__fish_use_subcommand" -a set -d "Apply a named profile"
    complete -c mprofile -n "__fish_seen_subcommand_from set" -a "(mprofile list 2>/dev/null)" -d "Profile"
  '';

  home.activation.monitorProfileDefault = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ln -sf profiles/${cfg.default}.conf "''${XDG_CONFIG_HOME:-$HOME/.config}/mango/active-profile.conf"
  '';
}
