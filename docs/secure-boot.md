# Secure Boot (akarnae)

UEFI Secure Boot for the `akarnae` host (ASUS PRIME Z370-A) using
[lanzaboote](https://github.com/nix-community/lanzaboote). lanzaboote replaces
`systemd-boot` with signed Unified Kernel Images (UKIs) and re-signs every NixOS
generation at rebuild time.

The host dual-boots Windows on a separate disk (`nvme1n1`, its own ESP). We enroll
our own keys **plus Microsoft's** (`--microsoft`), so the Windows Boot Manager keeps
validating and Windows is unaffected. There is no BitLocker, so no recovery-key prompt.

> Commands below are written for **fish** (the login shell on these hosts).

## Status

Verified working on akarnae (2026-09-29):

- `sbctl status` → `Secure Boot: enabled (user)`, `Setup Mode: disabled`, owner GUID is
  the machine's own key (generated with `sbctl create-keys`).
- `bootctl status` → `Secure Boot: enabled (user)`, `Measured UKI/OS: yes`.
- All lanzaboote generations on the ESP sign and verify; rebuilds re-sign correctly.
- LUKS: keyslot `0` = passphrase, keyslot `1` = `systemd-tpm2` token → disk auto-unlocks
  (passphrase fallback still works).

> This is UEFI Secure Boot, not legacy/CSM.
> `dbx` (forbidden signatures) is left untouched.

## How the pieces fit

- Config lives in `modules/nixos/secure-boot.nix` (`host.secureBoot`).
- Signing keys live in `/var/lib/sbctl` (the `pkiBundle`).
- Because `akarnae` uses **impermanence**, `/var/lib/sbctl` is persisted under
  `/persist`; without this the keys would be wiped on every boot.
- The ESP is only 1 GiB, so `host.secureBoot.configurationLimit` (default `10`)
  caps how many generations are kept on it.

## Prerequisites

- A recent backup: `rback backup`
- A NixOS live USB **and** the LUKS passphrase, in case of a bad boot
- CSM disabled / UEFI-only in firmware (already the case)
- Laptop/desktop physically accessible (you must press `DEL` at POST)

## Bootstrap overview (two rebuilds)

lanzaboote cannot install if the signing keys do not exist yet, and the keys must be
created **after** the impermanence bind mount for `/var/lib/sbctl` is active. So:

1. **Prep build** (Secure Boot still `false`) → reboot → create keys
2. **Enable build** (`host.secureBoot.enable = true`) → lanzaboote signs
3. Firmware Setup Mode → enroll keys → enable Secure Boot

---

## Phase 1 — prep the persistence bind mount

1. Apply the configuration as shipped (with `host.secureBoot.enable = false`):

   ```bash
   nh os switch
   ```

2. Reboot so the new bind mount takes effect:

   ```bash
   sudo reboot
   ```

3. Confirm `/var/lib/sbctl` is backed by `/persist`:

   ```bash
   findmnt /var/lib/sbctl
   # SOURCE should be .../persist/var/lib/sbctl (or a btrfs subvol on /persist)
   ```

## Phase 2 — create the signing keys

`sbctl` is only installed once lanzaboote is enabled, so for this one-time step run
it straight from nixpkgs:

```fish
sudo (nix build nixpkgs#sbctl --no-link --print-out-paths)/bin/sbctl create-keys
```

Confirm the keys landed in the persisted location:

```fish
sudo ls -R /persist/var/lib/sbctl/keys
```

> The private key (`keys/db/db.key`) now lives in `/persist`. Back it up somewhere
> safe if you care about rotating/restoring it. Never commit it.

## Phase 3 — enable lanzaboote and sign

1. Edit `hosts/akarnae/default.nix` and set:

   ```nix
   host.secureBoot.enable = true;
   ```

2. Rebuild:

   ```bash
   nh os switch
   ```

3. Verify everything on the ESP is signed:

   ```bash
   sudo sbctl verify
   # ✓ /boot/EFI/BOOT/BOOTX64.EFI is signed
   # ✓ /boot/EFI/Linux/nixos-generation-*.efi is signed
   # ✓ /boot/EFI/systemd/systemd-bootx64.efi is signed
   # ✗ .../kernel-*.efi is not signed  ← expected, ignore
   ```

If anything that should be signed is not, **stop** and fix it before touching the
firmware.

## Phase 4 — put the firmware in Setup Mode

UEFI refuses to enroll your keys while the ASUS Platform Key (PK) owns the firmware,
so you delete the PK once (this does **not** touch ASUS's private key, which is not on
the machine). It is fully reversible via **Restore Factory Keys**.

1. Reboot and press `DEL` at POST to enter BIOS.
2. Press `F7` for **Advanced Mode**.
3. Go to **Boot → Secure Boot**:
   - **Secure Boot Mode** → `Custom` (keep it Custom permanently; `Standard` would
     reload the factory keys and drop yours)
   - **OS Type** → `Windows UEFI mode`
   - *Note:* on some ASUS boards (e.g. PRIME Z370-A) the `Secure Boot Mode` entry is
     not visible. Key Management is only reachable in Custom mode, so if you can open
     Key Management you are already effectively in Custom. Secure Boot's on/off is
     driven by `OS Type`, not by Standard/Custom.
4. Enter **Key Management** → select **Delete PK** (a.k.a. "Reset to Setup Mode").
   Do **not** pick an option that erases **dbx**.
5. Press `F10` to save and exit, and boot back into NixOS.

## Phase 5 — enroll your keys

```fish
sudo sbctl enroll-keys --microsoft --firmware-builtin --ignore-immutable
```

- `--microsoft` — keeps Microsoft's KEK/db so **Windows** (and the **NVIDIA** GPU
  option ROM) still validate. Mandatory on this machine.
- `--firmware-builtin` — keeps the vendor default keys so ASUS firmware updates keep
  working.
- `--ignore-immutable` — NixOS marks the efivarfs entries immutable; sbctl clears the
  bit itself. Without it you get `File is immutable: .../KEK-*`.

Check:

```bash
sudo sbctl status
```

## Phase 6 — enable Secure Boot

`OS Type = Windows UEFI mode` was already set in Phase 4, so with your PK now
enrolled, Secure Boot activates on the next boot:

1. Reboot.
2. Verify (Phase 7). `sbctl status` should show **Secure Boot: enabled (user)**.

If it still shows disabled, re-enter BIOS → **Boot → Secure Boot** and confirm
**OS Type = Windows UEFI mode** (toggle it to `Other OS` and back to force a rewrite),
then `F10` to save. Also make sure **CSM is disabled**, otherwise Secure Boot is
greyed out.

To disable later: set **OS Type = Other OS**.

## Phase 7 — verify

On NixOS:

```bash
sbctl status          # Secure Boot: enabled (user)
bootctl status        # Secure Boot: enabled (user)
nvidia-smi            # NVIDIA driver still loads
sudo sbctl verify     # all signing still intact
```

On Windows:

1. Boot Windows.
2. `Win+R` → `msinfo32` → **Secure Boot State: On**.
3. Launch a kernel-level anti-cheat game to confirm it is happy.

Sanity check that rebuilds still sign while Secure Boot is on:

```bash
nh os switch
sudo sbctl verify
```

---

## Phase 8 — TPM2 auto-unlock (optional, do AFTER Secure Boot is stable)

This makes the LUKS disk unlock automatically at boot, but only while the Secure Boot
chain is intact (bound to **PCR 7**, the Secure Boot policy). The LUKS passphrase stays
as a fallback.

> On this host the initrd is systemd stage 1, which **implies `fallbackToPassword`**,
> so setting that option explicitly is a hard assertion error. The passphrase keeps
> working automatically if the TPM unseal fails.
> If you want a secret at boot, use `--tpm2-with-pin=yes` (see below).

### 8.1 NixOS config

Already applied in `hosts/akarnae/default.nix`:

```nix
security.tpm2.enable = true;
boot.initrd.availableKernelModules = [ "tpm_tis" "tpm_crb" ];

boot.initrd.luks.devices.crypted = {
  crypttabExtraOpts = [ "tpm2-device=auto" ];
};
```

Rebuild and reboot:

```fish
nh os switch; and sudo reboot
```

### 8.2 Enroll the TPM

Once booted, bind a new LUKS keyslot to the TPM. `bootctl status` reported
`Measured UKI: yes` / `Measured OS: yes`, so bind to **PCR 7 (Secure Boot policy) +
PCR 11 (UKI measurement)**:

```fish
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7+11 /dev/nvme0n1p3
```

Reboot — the disk should now unlock with no prompt. The passphrase still works.

Optional hardening: add a PIN (typed at boot) or extra PCRs:

```fish
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-with-pin=yes --tpm2-pcrs=7+11+14 /dev/nvme0n1p3
```

### 8.3 Re-enroll after firmware/dbx changes

Changing Secure Boot keys, updating `dbx`, or a BIOS update changes PCR 7, so
auto-unlock stops and you get the passphrase prompt. Re-run the `systemd-cryptenroll`
command above to re-bind. **Keep the passphrase keyslot forever.**

---

## Recovery / rollback

| Situation | Fix |
| --- | --- |
| Machine won't boot after key changes | `DEL` at POST → **Boot → Secure Boot → OS Type = Other OS** (disables Secure Boot), or **Key Management → Restore Factory Keys**. |
| Need to go back to plain systemd-boot | Set `host.secureBoot.enable = false;`, `nh os switch` (also re-enables the old bootloader). |
| Bad NixOS generation | Pick an older generation in the boot menu. |
| ESP full | Reduce `host.secureBoot.configurationLimit`, or clean old generations (`nh clean all`). |
| NixOS respin/reinstall wiped keys | A fresh disko install resets the ESP/LUKS; re-run Phases 2–6. |

Always keep the LUKS passphrase and a NixOS live USB available; disabling Secure Boot
in firmware always lets the machine boot so you can repair it.

## Troubleshooting

- **`sbctl enroll-keys` refuses** → the firmware is not in Setup Mode; delete the PK
  again (Phase 4). Verify with `sudo sbctl status`.
- **Windows no longer boots under Secure Boot** → you most likely enrolled without
  `--microsoft`; re-enroll with it, or disable Secure Boot and redo Phase 5.
- **NVIDIA driver fails after enabling Secure Boot** → Secure Boot can engage kernel
  lockdown and reject the proprietary module. If so, add `boot.kernelParams = [ "lockdown=none" ];`
  (weaker) or accept the module restriction. Confirm with `nvidia-smi`.
- **`sbctl verify` shows unsigned kernel files** → expected; lanzaboote signs the
  UKI/generation, not the raw `kernel-*.efi` blobs.
- **`systemd-boot-fallbackx64.efi` is unsigned** → expected and harmless; the firmware
  boots the signed `/EFI/systemd/systemd-bootx64.efi` (and the signed
  `/EFI/BOOT/BOOTX64.EFI`). The fallback stub is a leftover systemd-boot artifact that
  lanzaboote does not manage.

## Why Windows stays safe

- Windows has its own ESP on `nvme1n1`; lanzaboote only writes to the NixOS ESP on
  `nvme0n1p1`.
- `--microsoft` keeps Microsoft's KEK/db enrolled, so `bootmgfw.efi` still validates.
- No BitLocker → no recovery-key prompt.
