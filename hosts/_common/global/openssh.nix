{
  outputs,
  lib,
  config,
  ...
}: {
  services.openssh = {
    enable = true;
    settings = {
      # Harden
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  security.pam.enableSSHAgentAuth = true;
}
