{pkgs, ...}: {
  home.packages = with pkgs; [
    kubectl
    argo-rollouts
    kubie
    k9s
  ];

  home.persistence."/persist".directories = [".kube"];
}
