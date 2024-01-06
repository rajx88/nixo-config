rb:
	sudo nixos-rebuild switch --flake .#akarnae

hm:
	home-manager switch --flake .#rajkoh@akarnae

u: update 

update:
	nix flake update .
