{pkgs, ...}: {
  home.packages = with pkgs; [
    kubectl
    kubectx

    argo-rollouts
    kubie
    k9s
  ];

  home.persistence."/persist".directories = [".kube"];
}
