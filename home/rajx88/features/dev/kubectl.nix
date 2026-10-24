{ pkgs, ... }: {
  home.packages = with pkgs; [
    kubectl
    kubectx
    kubelogin-oidc # provides kubectl-oidc_login, used by Omni kubeconfigs
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
