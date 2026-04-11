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

  # Bump usage-cli to 3.2.0 to fix zsh completion regression (jdx/usage#558)
  usage-fix = final: prev: {
    usage = prev.usage.overrideAttrs (old: {
      version = "3.2.0";
      src = prev.fetchFromGitHub {
        owner = "jdx";
        repo = "usage";
        tag = "v3.2.0";
        hash = "sha256-0yonwl/2BIkGUs0uOBP+Pjo93NvLVK4QQQj/K4C4NNY=";
      };
      cargoDeps = final.rustPlatform.fetchCargoVendor {
        inherit (old) pname;
        version = "3.2.0";
        src = prev.fetchFromGitHub {
          owner = "jdx";
          repo = "usage";
          tag = "v3.2.0";
          hash = "sha256-0yonwl/2BIkGUs0uOBP+Pjo93NvLVK4QQQj/K4C4NNY=";
        };
        hash = "sha256-jxTN+La7Ye2okRZGAY6niIvvRf2E4vFFHd1nny7JJDo=";
      };
      checkFlags = (old.checkFlags or []) ++ [
        # These tests try to invoke the built binary which isn't available in the sandbox
        "--skip=test_zsh_complete_word_output_format"
        "--skip=test_complete_path_adds_trailing_slash_for_directories"
      ];
    });
  };

  # Claude Code from sadjow/claude-code-nix (follows main for hourly updates)
  claude-code = inputs.claude-code.overlays.default;
}
