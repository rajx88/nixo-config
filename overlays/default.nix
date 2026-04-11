{
  outputs,
  inputs,
}: {
  # Adds pkgs.stable == inputs.nixpkgs-stable.legacyPackages.${pkgs.system}
  stable = final: _: {
    stable = inputs.nixpkgs-stable.legacyPackages.${final.stdenv.hostPlatform.system};
  };

  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs {pkgs = final;};

  # Claude Code from sadjow/claude-code-nix (follows main for hourly updates)
  claude-code = inputs.claude-code.overlays.default;
}
