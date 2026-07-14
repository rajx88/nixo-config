{pkgs, ...}: {
  home.packages = [pkgs.radar];

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
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };

  systemd.user.services.radar-auth-watch = {
    Unit = {
      Description = "Stop radar when AWS/EKS auth expires, restart when it returns";
    };
    Service = {
      Type = "oneshot";
      ExecStart = let
        script = pkgs.writeShellScript "radar-auth-watch" ''
          if ${pkgs.kubectl}/bin/kubectl auth can-i get pods --namespace=default &>/dev/null; then
            systemctl --user start radar
          else
            systemctl --user stop radar
          fi
        '';
      in "${script}";
    };
  };

  systemd.user.timers.radar-auth-watch = {
    Unit = {
      Description = "Check EKS auth every minute";
    };
    Timer = {
      OnBootSec = "60s";
      OnUnitActiveSec = "60s";
    };
    Install = {
      WantedBy = ["timers.target"];
    };
  };
}
