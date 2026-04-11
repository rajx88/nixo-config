DISK := "nvme0n1"
MACHINE := "akarnae"
ENC_PASS := ""
user := env('USER')

rb:
  nh os switch

build:
  nh os build

debug:
  nh os switch -- --show-trace --verbose

hms:
  nh home switch

clean:
  nh clean all --keep-since 7d --keep 3

arch:
	just hm arch

wsl:
	just hm wsl

hm $MACHINE:
	home-manager switch --flake .#{{user}}@{{MACHINE}}

up:
  nix flake update

# Update specific input
# usage: make upp i=home-manager
upp:
  nix flake update $(i)

####
# installation stuff
####

nix-install:
	sudo nixos-install --no-root-passwd --flake '.#${MACHINE}' --impure

format-disks-luks-btrfs-impermanence: enc-pass
	sudo nix run github:nix-community/disko --extra-experimental-features nix-command --extra-experimental-features flakes -- --mode disko ./tmpl/efi-luks-btrfs-impermanence-swap.nix --arg disks '[ "/dev/${DISK}" ]'

enc-pass:
	echo -n "${ENC_PASS}" > /tmp/secret.key

generate-config:
	sudo nixos-generate-config --no-filesystems --root /mnt

cp-config: generate-config
	mkdir -p ./hosts/${MACHINE}
	cp /mnt/etc/nixos/hardware-configuration.nix ./hosts/${MACHINE}/hardware-configuration.nix

set-password:
	bash  ./scripts/change-pass.sh
