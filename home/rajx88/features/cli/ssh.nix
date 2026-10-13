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
      "*" = {
        IdentityAgent = "~/.1password/agent.sock";
      };
    };
  };

  home.persistence."/persist".directories = [ ".ssh" ];
}
