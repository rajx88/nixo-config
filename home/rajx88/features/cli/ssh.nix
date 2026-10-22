{
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

  home.persistence."/persist".directories = [ ".ssh" ];
}
