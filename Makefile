
rb:
	sudo nixos-rebuild switch --flake .#akarnae

hm:
	home-manager switch --flake .#rajkoh@akarnae

update:
	nix flake update
