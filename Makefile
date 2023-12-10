
rebuild:
	nixos-rebuild switch --flake .#akarnae

hm:
	home-manager --flake .#rajkoh@akarnae
