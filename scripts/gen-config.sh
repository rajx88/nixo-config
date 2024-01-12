
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

function format_manual {
    parted "$DISK" -- mklabel gpt
    echo "Making 1Gb ESP boot on partition 1"
    parted "$DISK" -- mkpart ESP fat32 1MiB 1GiB
    parted "$DISK" -- set 1 boot on
    mkfs.vfat "$DISK"1

    echo "Making 8Gb Swap on partition 2"
    parted "$DISK" -- mkpart Swap linux-swap 1GiB 9GiB
    mkswap -L Swap "$DISK"2
    swapon "$DISK"2

    echo "Making the rest BTRFS on partition 3"
    parted "$DISK" -- mkpart primary 9GiB 100%
    mkfs.btrfs -f -L Butter "$DISK"3

    echo "Making BTRFS subvolumes"
    mount "$DISK"3 /mnt
    btrfs subvolume create /mnt/root
    btrfs subvolume create /mnt/home
    btrfs subvolume create /mnt/nix
    btrfs subvolume create /mnt/persist
    btrfs subvolume create /mnt/log
    btrfs subvolume create /mnt/machines
    btrfs subvolume create /mnt/portables

    # We then take an empty *readonly* snapshot of the root subvolume,
    # which we'll eventually rollback to on every boot.
    echo "Making empty snapshot of root"
    btrfs subvolume snapshot -r /mnt/ /mnt/root-blank

    umount /mnt

    # Mount the directories

    mount -o subvol=root,compress=zstd,noatime "$DISK"3 /mnt
    mkdir /mnt/home
    mount -o subvol=home,compress=zstd,noatime "$DISK"3 /mnt/home
    mkdir /mnt/nix
    mount -o subvol=nix,compress=zstd,noatime "$DISK"3 /mnt/nix
    mkdir /mnt/persist
    mount -o subvol=persist,compress=zstd,noatime "$DISK"3 /mnt/persist
    mkdir -p /mnt/var/log
    mount -o subvol=log,compress=zstd,noatime "$DISK"3 /mnt/var/log
    mkdir -p /mnt/var/lib/machines
    mount -o subvol=machines,compress=zstd,noatime "$DISK"3 /mnt/var/lib/machines
    mkdir -p /mnt/var/lib/portables
    mount -o subvol=portables,compress=zstd,noatime "$DISK"3 /mnt/var/lib/portables
    # don't forget this!
    mkdir /mnt/boot
    mount "$DISK"1 /mnt/boot

}

function build_file_system {
    echo "Making File system"
    DISK=/dev/vda
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
NIXDIR="$SCRIPTDIR/../etc/nixos"

get_user_info
build_file_system
generate_config
install_nix
echo "Install completed!"
echo "Reboot to use NixOS"