{pkgs, ...}: {
  home.packages = with pkgs; [
    kubectl
    kubie
  ];

  home.persistence."/persist".directories = [".kube"];
}
