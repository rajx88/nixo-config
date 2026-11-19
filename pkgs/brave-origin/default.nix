# Brave Origin, vendored from nixpkgs (removed upstream on 2026-11-03, see
# NixOS/nixpkgs#... "no committers among its maintainers"). Upstream the
# package is only a wrapper around Brave's official .deb releases, so this
# copies the derivation and keeps tracking the same artifacts.
# Bumped by `./pkgs/update.sh brave-origin`.
{
  callPackage,
  ...
}:

let
  pkg = rec {
    pname = "brave-origin";
    version = "1.100.58";
    flavor = "origin";

    archives = {
      x86_64-linux = {
        url = "https://github.com/brave/brave-browser/releases/download/v${version}/brave-origin_${version}_amd64.deb";
        hash = "sha256-TM7BTRt8Nkh+HYShyrQkq5TpO5S0F2IG5MEaMiE9xh0=";
      };
    };
  };

  # Flavor-specific paths, matching nixpkgs' brave/default.nix.
  flavorData = {
    optStem = "brave-origin";
    fileStem = "brave-origin";
    appIdStem = "com.brave.Origin";
    darwinStem = "Brave Origin";
    changelogFile = "CHANGELOG_DESKTOP_ORIGIN.md";
    homepage = "https://brave.com/origin/";
    innerBinary = "brave";
  };
in
callPackage ((import ./make-brave.nix) (pkg // flavorData)) { }
