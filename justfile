DISK := "nvme0n1"
MACHINE := "akarnae"
ENC_PASS := "" 
user := env('USER')

arch:
	just hm arch

wsl:
	just hm wsl 

hm $MACHINE:
	home-manager switch --flake .#{{user}}@{{MACHINE}}

rb:
  #!/usr/bin/env bash
  old=$(readlink -f /nix/var/nix/profiles/system)
  nixos-rebuild switch --flake .#$HOSTNAME --sudo
  new=$(readlink -f /nix/var/nix/profiles/system)
  
  if [ "$old" != "$new" ]; then
    echo -e "\n=== Changes applied ==="
    applied_diff=$(mktemp)
    nix store diff-closures $old $new | tee "$applied_diff"

    # Compare applied diff with latest predicted diff (from `up`)
    latest_diff=$(ls -t .flake-diffs/$HOSTNAME-*.diff 2>/dev/null | head -1)
    if [ -n "$latest_diff" ]; then
      if diff -q "$latest_diff" "$applied_diff" > /dev/null 2>&1; then
        echo -e "\n✓ Changes match prediction ($latest_diff)"
        rm -f "$applied_diff"
      else
        echo -e "\n⚠ WARNING: Applied changes differ from prediction!"
        echo "Predicted: $latest_diff"
        echo "Applied diff kept at: $applied_diff"
      fi
    else
      echo -e "\nNo predicted diff found (run 'j up' first)."
      rm -f "$applied_diff"
    fi
  else
    echo "No changes - system already up to date"
  fi


debug:
  nixos-rebuild switch --flake .#$HOSTNAME --sudo --show-trace --verbose

up:
  nix flake update

build:
  #!/usr/bin/env bash
  echo "Building new system..."
  nixos-rebuild build --flake .#$HOSTNAME --sudo

check-changes:
  #!/usr/bin/env bash
  mkdir -p .flake-diffs
  echo "Building new system..."
  new=$(nix build --print-out-paths ".#nixosConfigurations.${HOSTNAME}.config.system.build.toplevel" --no-link)
  
  old=$(readlink -f /nix/var/nix/profiles/system)
  
  if [ -z "$new" ] || [ ! -d "$new" ]; then
    echo "Build failed"
    exit 1
  fi

  timestamp=$(date '+%Y-%m-%d_%H-%M-%S')
  echo -e "\n=== Changes that will be applied ==="
  tmp_diff=$(mktemp)
  nix store diff-closures "$old" "$new" | tee "$tmp_diff"

  if [ -s "$tmp_diff" ]; then
    mv "$tmp_diff" ".flake-diffs/$HOSTNAME-$timestamp.diff"
    echo -e "\nDiff saved to .flake-diffs/$HOSTNAME-$timestamp.diff"
    echo "Run 'j rb' to apply these changes"
  else
    echo "No differences detected; not saving diff file"
    rm -f "$tmp_diff"
  fi


# Show recent flake diffs
diff-show:
  #!/usr/bin/env bash
  if [ ! -d .flake-diffs ]; then
    echo "No diffs yet. Run 'j up' to generate a preview diff."
    exit 0
  fi
  echo "Recent flake diffs:"
  ls -lht .flake-diffs/ | head -10

# Show specific diff file (usage: j diff-view akarnae-2026-01-22_09-28-19.diff)
diff-view $file:
  cat .flake-diffs/{{file}}

# Update specific input
# usage: make upp i=home-manager
upp:
  nix flake update $(i)

clean:
  # remove all generations older than 7 days
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 7d

gc:
  # garbage collect all unused nix store entries
  sudo nix-collect-garbage --delete-old

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
