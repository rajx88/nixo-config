{
  outputs,
  inputs,
}:
{
  # Adds pkgs.stable == inputs.nixpkgs-stable.legacyPackages.${pkgs.system}
  stable = final: _: {
    stable = inputs.nixpkgs-stable.legacyPackages.${final.stdenv.hostPlatform.system};
  };

  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # Luciole from upstream (github:noctalia-dev/luciole) so `pkgs.luciole` is
  # available to modules and keybinds.
  luciole = inputs.luciole.overlays.default;

  # Claude Code from sadjow/claude-code-nix (follows main for hourly updates)
  claude-code = inputs.claude-code.overlays.default;
}
