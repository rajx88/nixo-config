{
  config,
  pkgs,
  ...
}: let
  dockerEnabled = config.virtualisation.docker.enable;
in {
  virtualisation.podman = {
    enable = true;
    dockerCompat = !dockerEnabled;
    dockerSocket.enable = !dockerEnabled;
    defaultNetwork.settings.dns_enabled = true;

    extraPackages = [
      pkgs.podman-compose
    ];
  };

  environment.persistence = {
    "/persist".directories = [
      "/var/lib/containers"
    ];
  };
}
