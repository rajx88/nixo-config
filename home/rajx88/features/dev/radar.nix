{pkgs, ...}: {
  home.packages = [pkgs.radar pkgs.radar-desktop];

  home.persistence."/persist".directories = [".radar"];

  systemd.user.services.radar = {
    Unit = {
      Description = "Radar Kubernetes MCP server";
      After = ["network.target"];
    };
    Service = {
      Type = "exec";
      ExecStart = "${pkgs.radar}/bin/radar";
      Restart = "on-failure";
      RestartSec = "5s";
      Environment = ["KUBECONFIG=%h/.kube/config:%h/.kube/aws-eks"];
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}
