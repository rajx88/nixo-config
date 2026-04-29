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

    # monitorrule lines
    monitorrules = map (m: let
      parts = lib.splitString "x" m.position;
      hasExplicitPos = builtins.length parts == 2 && builtins.match "[0-9]+" (builtins.elemAt parts 0) != null;
      px = builtins.elemAt parts 0;
      py = builtins.elemAt parts 1;
      posStr = lib.optionalString hasExplicitPos ",x:${px},y:${py}";
    in "monitorrule = name:^${m.name}$,width:${toString m.width},height:${toString m.height},refresh:${toString m.refreshRate}${posStr},scale:1"
    ) enabledMonitors;

    # workspace bind lines
    wsBinds = lib.concatMap (m:
      map (ws: "bind = SUPER,${wsToKey ws},viewcrossmon,${toString ws},${m.name}") m.workspaces
      ++ map (ws: "bind = SUPER+SHIFT,${wsToKey ws},tagcrossmon,${toString ws},${m.name}") m.workspaces
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

  # Monitor profile switcher script
  monitorProfileScript = pkgs.writeShellScriptBin "monitor-profile" ''
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
      mmsg -s -d reload_config
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
      "") echo "Usage: monitor-profile <auto|list|PROFILE>" >&2; exit 1 ;;
      *) apply_profile "$1" ;;
    esac
  '';

  # Menu script
  monitorProfileMenuScript = pkgs.writeShellScriptBin "monitor-profile-menu" ''
    choice=$(printf '%s\n' ${lib.escapeShellArgs profileNames} | ${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt "Monitor Profile: ")
    [ -n "$choice" ] && monitor-profile "$choice"
  '';

in lib.mkIf (cfg.enable or false) {
  xdg.configFile = snippetFiles;

  home.packages = [
    monitorProfileScript
    monitorProfileMenuScript
    pkgs.fuzzel
    pkgs.jq
    pkgs.wlr-randr
  ];

  home.activation.monitorProfileDefault = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ln -sf profiles/${cfg.default}.conf "''${XDG_CONFIG_HOME:-$HOME/.config}/mango/active-profile.conf"
  '';
}
