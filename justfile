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

# Home-manager is wired into the NixOS config on yuji/akarnae, so a plain
# `nh home switch` cannot find a standalone #homeConfigurations.<user>@<host>.
# Use the OS switch (which also builds & activates the embedded home config).
hms:
  nh os switch

clean:
  nh clean all --keep-since 7d --keep 3

arch:
	just rb

hm $MACHINE:
	nh os switch

# Flake refs resolve through api.github.com (commits/<ref>), which allows only 60
# unauthenticated requests/hour per IP — shared with pkgs/update.sh (~10 per run),
# gh itself and every other client on this IP, so one uncached run can 403 (and
# then silently reuse cached revisions). This shell prefix authenticates those
# requests with the gh CLI credential, read *inside* the shell: the token never
# appears in this file, in just's echo/verbose/dry-run output, or as an argument
# to nix. Without a gh credential the prefix is a no-op (nix stays anonymous).
nix-auth := 't=$(gh auth token 2>/dev/null); if [ -n "$t" ]; then export NIX_CONFIG="$(printf "%s\naccess-tokens = github.com=%s" "${NIX_CONFIG:-}" "$t")"; fi;'

up:
  @{{nix-auth}} nix flake update

# Update specific input
# usage: just upp home-manager
upp i:
  @{{nix-auth}} nix flake update {{i}}

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

####
# secure boot / tpm
####

# Enroll a fresh TPM2 keyslot for the LUKS root (auto-unlock). Run after a BIOS update
# or any Secure Boot key/dbx change. Binds PCR 7 (Secure Boot policy) only: PCR 11
# would change on every rebuild and re-prompt for the passphrase.
tpm-enroll:
	sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 /dev/nvme0n1p3

# Drop the TPM2 keyslot and go back to passphrase-only boot.
tpm-wipe:
	sudo systemd-cryptenroll --wipe-slot=tpm2 /dev/nvme0n1p3

# Show Secure Boot status and the LUKS tokens.
sb-status:
	sbctl status
	sudo cryptsetup luksDump /dev/nvme0n1p3 | grep -A2 '^Tokens:'

