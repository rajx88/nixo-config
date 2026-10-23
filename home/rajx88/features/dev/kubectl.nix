{ pkgs, ... }: {
  home.packages = with pkgs; [
    kubectl
    kubectx
    talosctl
    omnictl

    argo-rollouts
    kubie
    k9s
  ];

  home.persistence."/persist".directories = [
    ".kube"
    ".talos"
    ".config/omni"
  ];
}
