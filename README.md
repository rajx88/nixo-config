# Nixos Config


```bash
curl https://gitlab.com/rajkohlen/nixos-config/-/raw/main/disko-config.nix -o /tmp/disko-config.nix
```

```bash
sudo nix run --extra-experimental-features nix-command --extra-experimental-features flakes github:nix-community/disko -- --mode disko /tmp/disko-config.nix

```

