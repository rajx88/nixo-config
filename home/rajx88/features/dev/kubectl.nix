{ pkgs, ... }: {
  home.packages = with pkgs; [
    kubectl
    kubectx
    talosctl

    argo-rollouts
    kubie
    k9s
  ];

  home.persistence."/persist".directories = [
    ".kube"
    ".talos"
  ];
}
