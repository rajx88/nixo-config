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

  # Handy from the upstream flake (github:cjpais/Handy) so `pkgs.handy` tracks
  # the latest release via `nix flake update handy`; nixpkgs' handy lags the
  # unstable branch by days/weeks. Upstream's flake omits sqlite from its inputs
  # (needed since nixpkgs #537108 made libsqlite3-sys link the system lib), so
  # patch that in here. Drop this line once upstream fixes their flake.
  handy = final: _prev: {
    handy = (inputs.handy.packages.${final.stdenv.hostPlatform.system}.handy).overrideAttrs (old: {
      buildInputs = (old.buildInputs or [ ]) ++ [ final.sqlite ];
    });
  };
}
