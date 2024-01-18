# Nixos Config

```bash
nix run github:nix-community/nixos-anywhere -- --flake .#akarnae
```
```bash
echo -n "password" > /tmp/secret.key
```

```bash
sudo nixos-install --flake '.#akarnae' --impure
```

insert the following in `/etc/nixos/configuration.nix`:

```nix
nix = {
  package = pkgs.nixFlakes;
  extraOptions = "experimental-features = nix-command flakes";
}
```
This is only needed when starting from scratch.

```bash
curl https://gitlab.com/rajkohlen/nixos-config/-/raw/main/disko-config.nix -o /tmp/disko-config.nix
```
The following is used to see the disks. This is then used as argument in the disko run.
```bash
lsblk 
```
```bash
sudo nix run github:nix-community/disko -- --mode disko /tmp/disko-config.nix --arg disks '[ "/dev/nvme0n1" ]'
```
if the above command does not work use the command below:
```bash
sudo nix run --extra-experimental-features nix-command --extra-experimental-features flakes github:nix-community/disko -- --mode disko /tmp/disko-config.nix --arg disks '[ "/dev/nvme0n1" ]'

```
```bash
sudo nixos-generate-config --no-filesystems --root /mnt
```

```bash
sudo mv /tmp/disko-config.nix /mnt/etc/nixos
```

```bash
sudo nano /mnt/etc/nixos/configuration.nix
```

```bash
imports =
 [ # Include the results of the hardware scan.
   ./hardware-configuration.nix
   "${builtins.fetchTarball "https://github.com/nix-community/disko/archive/master.tar.gz"}/module.nix"
   ./disko-config.nix
 ];
```

```bash
sudo nixos-install
sudo reboot
```