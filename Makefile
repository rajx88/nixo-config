DISK="nvme0n1"
MACHINE="akarnae"
ENC_PASS=""

rb:
	sudo nixos-rebuild switch --flake .#akarnae

hm:
	home-manager switch --flake .#rajkoh@akarnae

u: update 

update:
	nix flake update .

nix-install: 
	sudo nixos-install --flake '.#${MACHINE}' --impure

format-disks-luks-btrfs-impermanence: enc-pass
	sudo nix run github:nix-community/disko -- --mode disko ./tmpl/efi-luks-btrfs-impermanence-swap.nix --arg disks '[ /dev/${DISK} ]'

enc-pass:
	echo -n "${ENC_PASS}" > /tmp/secret.key

generate-config:
	sudo nixos-generate-config --no-filesystems --root /mnt

cp-config: generate-config
	mkdir -p ./hosts/${MACHINE}
	cp /mnt/etc/nixos/hardware-configuration.nix ./hosts/${MACHINE}/hardware-configuration.nix
