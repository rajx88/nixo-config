# Nixos Config


```bash
curl https://gitlab.com/rajkohlen/nixos-config/-/raw/main/disko-config.nix -o /tmp/disko-config.nix
```

```bash
sudo nix run --extra-experimental-features nix-command --extra-experimental-features flakes github:nix-community/disko -- --mode disko /tmp/disko-config.nix

```
```bash
nixos-generate-config --no-filesystems --root /mnt
```

```bash
mv /tmp/disko-config.nix /mnt/etc/nixos
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
nixos-install
reboot
```