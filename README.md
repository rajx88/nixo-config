# Nixos Configuration

This is my personal Nixos configuration. The steps below explain how to get the configuration up and running.

## Installation

There are a few steps to execute before installing the system. This is depending on what type of construction is chosen. For now the standard is a Luks enabled BTRFS with impermenance. The commands are wrapped inside the Makefile.

### Make

Using the following command enables a shell with the neccessary tools:

```bash
nix-shell -p git neovim gnumake
```

Choose the correct disk to wipe:

```bash
lsblk
```

Format the disk the input is displayed in the terminal so be careful:

```bash
make format-disks-luks-btrfs-impermanence ENC_PASS=your_pass_for_the_encryption
```

For new systems execute:

```bash
make cp-config MACHINE=YOURMACHINEHERE
```

create password but you have to create the directory first:
```bash
sudo mkdir -p /mnt/persist/password
```
then execute the following command to set the password:
```bash
make set-password
```


Make sure to create the default.nix file containing the configuration for this host. Add this new host to the flake.nix file.

Now install the system, while installing the install will prompt for a root password:

```bash
make nix-install MACHINE=YOURMACHINEHERE
```

After the installation just reboot.

```bash
sudo reboot
```

## Manual installation

Choose the correct disk to wipe:

```bash
lsblk
```

Set the password for disk encryption, input is displayed in the terminal so be careful:

```bash
echo -n "password" > /tmp/secret.key
```

To format the disk simply execute the following:

```bash
sudo nix run github:nix-community/disko -- --mode disko ./tmpl/efi-luks-btrfs-impermanence-swap.nix --arg disks '[ "YOURDISKHERE" ]'

```

For new systems execute:

```bash
sudo nixos-generate-config --no-filesystems --root /mnt
mkdir -p ./hosts/YOURMACHINE
cp /mnt/etc/nixos/hardware-configuration.nix ./hosts/YOURMACHINE/hardware-configuration.nix
```

Make sure to create the default.nix file containing the configuration for this host. Add this new host to the flake.nix file.

Now install the system, while installing the install will prompt for a root password:

```bash
sudo nixos-install --flake '.#akarnae' --impure
```

After the installation just reboot.

```bash
sudo reboot
```

## Things to look at in the future

The following things are potentially interesting to include into this configuration.

### Nixos anywhere

This will make it easy to install Nixos on systems that are reachable from a Nixos system. At this point in time I could not find a way to locally install via nixos anywhere hence the "manual" installation

```bash
nix run github:nix-community/nixos-anywhere -- --flake .#akarnae
```

