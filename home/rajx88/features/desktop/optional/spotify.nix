{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.spicetify-nix.homeManagerModules.default
  ];

  programs.spicetify = let
    spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  in {
    enable = true;
    # theme = spicePkgs.themes.comfy;
    theme = spicePkgs.themes.catppuccin;
    colorScheme = "mocha";

    enabledExtensions = with spicePkgs.extensions; [
      adblock
      # hidePodcasts
      shuffle # shuffle+ (special characters are sanitized out of extension names)
    ];

    # Fix dropdown menus on Wayland by forcing X11 mode
    spotifyPackage = pkgs.spotify.overrideAttrs (oldAttrs: {
      postInstall =
        (oldAttrs.postInstall or "")
        + ''
          wrapProgram $out/bin/spotify \
            --add-flags "--disable-features=WaylandWindowDecorations" \
            --set NIXOS_OZONE_WL ""
        '';
    });
  };

  home.persistence."/persist".directories = [
    ".config/spotify"
  ];
}
