{
  description = "Your new nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hardware.url = "github:nixos/nixos-hardware";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

 outputs = { self, nixpkgs, home-manager, disko, ... }@inputs:
  let
    inherit (self) outputs;
    
    lib = nixpkgs.lib // home-manager.lib;
    systems = [ "x86_64-linux" "aarch64-linux" ];

    forAllSystems = f: lib.genAttrs systems (system: f pkgsFor.${system});

    pkgsFor = lib.genAttrs systems (system: import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    });

  in 
  {
    inherit lib;

    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};

    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (pkgs: import ./pkgs { inherit pkgs; });

    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (pkgs: pkgs.nixpkgs-fmt);

    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules = import ./modules/nixos;

    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    homeManagerModules = import ./modules/home-manager;

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      akarnae= lib.nixosSystem {
        modules = [ 
          disko.nixosModules.disko
	  { disko.devices.disk.main.device = "/dev/nvme0n1"; }
	  ./hosts/akarnae
	];
        specialArgs = {inherit inputs outputs;};
      };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      "rajkoh@akarnae" = lib.homeManagerConfiguration {
        extraSpecialArgs = { inherit inputs outputs; };
        modules = [ ./home/rajkoh/akarnae.nix ];
        pkgs = pkgsFor.x86_64-linux;
      };
    };
  };
}
