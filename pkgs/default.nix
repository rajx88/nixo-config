# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs}: {
  # example = pkgs.callPackage ./example { };
  worktrunk = pkgs.callPackage ./worktrunk {};
  opencode = pkgs.callPackage ./opencode {};
  pi-coding-agent = pkgs.callPackage ./pi-coding-agent {};
  codegraph = pkgs.callPackage ./codegraph {};
  brave-origin = pkgs.callPackage ./brave-origin {};
  omp = pkgs.callPackage ./omp {};
  herdr = pkgs.callPackage ./herdr {};
  cursor = pkgs.callPackage ./cursor {};
  icm = pkgs.callPackage ./icm {};
  radar = pkgs.callPackage ./radar {};
  radar-desktop = pkgs.callPackage ./radar-desktop {};
}
