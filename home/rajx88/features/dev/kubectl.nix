{pkgs, ...}: {
  home.packages = with pkgs; [
    kubectl
    kubie
    k9s
  ];

  home.persistence."/persist".directories = [".kube"];
}
