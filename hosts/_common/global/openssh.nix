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
      PermitRootLogin = false;
    };
  };

  security.pam.enableSSHAgentAuth = true;
}
