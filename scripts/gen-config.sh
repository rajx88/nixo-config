 # create configuration
echo "Generating Config"
# nixos-generate-config --root /mnt
# For disko we generate a config with the --no-filesystems option
nixos-generate-config --no-filesystems --root /mnt
echo

# Copy over our nixos config
echo "Copying over our nixos configs"
# Copy config files to new install

cp -r "$NIXDIR"/* /mnt/etc/nixos
# Copy these files into persist volume (we copy from destination to include the hardware.nix)
mkdir -p /mnt/persist/etc/nixos
cp -r /mnt/etc/nixos/* /mnt/persist/etc/nixos/

echo "Copying over script files"
mkdir -p /mnt/persist/scripts
cp "$SCRIPTDIR"/* /mnt/persist/scripts

echo "Creating persist git path"
mkdir -p /mnt/persist/git
sudo chown 1000:users /mnt/persist/git

echo "Creating trash folder for user 1000 in /persist"
mkdir -p /mnt/persist/.Trash-1000
sudo chown 1000:users /mnt/persist/.Trash-1000
sudo chmod 700 /mnt/persist/.Trash-1000

# Write the password we entered earlier
mkdir -p /mnt/persist/passwords
mkpasswd -m sha-512 "$PASS1" > /mnt/persist/passwords/user
echo "Password file is:"
ls -lh /mnt/persist/passwords/user
echo "Config generation complete!"   