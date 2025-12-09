{pkgs, ...}: {
  virtualisation.podman = {
    enable = false;
    dockerCompat = true;
    dockerSocket.enable = true;
    defaultNetwork.settings.dns_enabled = true;

    extraPackages = [
      pkgs.podman-compose
    ];
  };

  virtualisation.docker = {
    enable = true;
    rootless.enable = true;
    rootless.setSocketVariable = true;
  };

  environment.persistence = {
    "/persist".directories = [
      "/var/lib/containers"
    ];
  };
}
