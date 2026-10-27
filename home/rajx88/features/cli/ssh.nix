{ config, lib, ... }: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = [
      "~/.ssh/config_sshconfgen"
      "~/.ssh/1Password/config"
    ];
    settings = {
      docker01 = {
        User = "aether";
        IdentitiesOnly = true;
        IdentityFile = "~/.ssh/1Password/SHA256_r_SMiVWPAZotgvHtllb8iDKiikLOGB+VoRM17mBtV3w.pub";
      };
      nas = {
        User = "appeltaartu";
        IdentitiesOnly = true;
        IdentityFile = "~/.ssh/1Password/SHA256_r_SMiVWPAZotgvHtllb8iDKiikLOGB+VoRM17mBtV3w.pub";
      };
      proxmox = {
        User = "root";
        IdentitiesOnly = true;
        IdentityFile = "~/.ssh/1Password/SHA256_r_SMiVWPAZotgvHtllb8iDKiikLOGB+VoRM17mBtV3w.pub";
      };
      # Alpine LXC 103, the primary Pi-hole. The name resolves through Pi-hole
      # itself (dns.hosts on 103, replicated to docker01); use `ssh root@192.168.1.53`
      # when DNS is the thing that is broken.
      pihole02 = {
        User = "root";
        IdentitiesOnly = true;
        IdentityFile = "~/.ssh/1Password/SHA256_r_SMiVWPAZotgvHtllb8iDKiikLOGB+VoRM17mBtV3w.pub";
      };
      "*" = {
        IdentityAgent = "~/.1password/agent.sock";
      };
    };
  };

  # Sandboxed apps (Bruno is an appimageTools/bwrap FHS env) run in a user
  # namespace that only maps our uid, so the root-owned Nix store symlink target
  # shows up as "nobody" and OpenSSH aborts with "Bad owner or permissions on
  # ~/.ssh/config". Install a user-owned copy instead of home-manager's symlink.
  home.file.".ssh/config".enable = false;
  home.activation.sshConfigCopy = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run rm -f "$HOME/.ssh/config"
    run install -Dm600 ${config.home.file.".ssh/config".source} "$HOME/.ssh/config"
  '';

  home.persistence."/persist".directories = [ ".ssh" ];
}
