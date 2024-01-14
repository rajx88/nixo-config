
function prompt {
	read -n 1 -srp $'Is this correct? (y/N) ' key
	echo
	if [ "$key" != 'y' ]; then 
        exit
    fi
}

function format_disko {
    # format the disk
    # wipefs -a -f $DISK
    NIX="nix --extra-experimental-features 'nix-command flakes'"
    disko="$NIX run github:nix-community/disko --"
    DCONFIG="/root/nixos-main/etc/nixos/disko-config.nix"
    DISKO_CMD="$disko --mode zap_create_mount $DCONFIG --arg disks '[ ""\"""$DISK""\""" ]'"
    # DISKO_CMD="nix --extra-experimental-features 'nix-command flakes' run github:nix-community/disko -- --mode zap_create_mount /root/nixos-main/etc/nixos/disko-config.nix --arg disks '[ ""\"""$DISK""\""" ]'"
    eval "$DISKO_CMD"
    # nix --extra-experimental-features nix-command --extra-experimental-features flakes run github:nix-community/disko -- --mode zap_create_mount /root/nixos-main/etc/nixos/disko-config.nix --arg disks '[ "/dev/vda" ]'
    echo "Making empty snapshot of root"
    MOUNT="/mnt2"
    mkdir $MOUNT
    mount -o subvol=@ "$DISK"3 "$MOUNT"
    # Make tmp and srv directories so subvolumes are not autocreated
    # by systemd, stopping deletion of root subvolume
    mkdir -p "$MOUNT/root/srv"
    mkdir -p "$MOUNT/root/tmp"
    btrfs subvolume snapshot -r /mnt2/root /mnt2/root-blank
    btrfs subvolume list /mnt2
    umount "$MOUNT"
}

function build_file_system {
    echo "Making File system"
    DISK=/dev/nvme0n1
    echo
    echo "Drive to erase and install nixos on is: $DISK"
    read -n 1 -srp $'Is this ok? (Y/n) ' key
    echo
    if [ "$key" == 'n' ]; then                                                                                             
        lsblk
        read -rp "Enter New Disk: " DISK
        echo "Nixos will be installed on: $DISK"  
        prompt
    fi

    echo "WARNING - About to erase $DISK and install NixOS."
    prompt

    # format_manual
    format_disko

    echo "Disk configuration complete!"
    echo
}

function install_nix {
    echo
    read -n 1 -srp $'Would you like to install nixos now? (Y/n) ' key
    echo
    if [ "$key" == 'n' ]; then                                                                                      
        exit
    else 
        nixos-install
    fi
}

# Make script independent of which dir it was run from
SCRIPTDIR=$(dirname "$0")
NIXDIR="/etc/nixos"

build_file_system
generate_config
install_nix
echo "Install completed!"
echo "Reboot to use NixOS"