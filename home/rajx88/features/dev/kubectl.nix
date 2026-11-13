{
  pkgs,
  lib,
  ...
}:
let
  mkZshCompletion = import ../../lib/zsh-completion.nix { inherit pkgs lib; };
in
{
  home.packages =
    (with pkgs; [
      kubectl
      kubectx
      kubelogin-oidc # provides kubectl-oidc_login, used by Omni kubeconfigs
      talosctl
      omnictl

      argo-rollouts
      kubie
      k9s
    ])
    ++ [
      # Generated at build time instead of spawning these on every shell init.
      (mkZshCompletion "kubie" pkgs.kubie "kubie" "generate-completion zsh")
      (mkZshCompletion "kubectl-argo-rollouts" pkgs.argo-rollouts "kubectl-argo-rollouts"
        "completion zsh"
      )
      (mkZshCompletion "kubelogin" pkgs.kubelogin-oidc "kubectl-oidc_login" "completion zsh")
    ];

  # The generated script compdefs `kubelogin`; also complete the kubectl plugin
  # binary name users actually type.
  home.file.".local/completions/_kubectl-oidc_login".text = ''
    #compdef kubectl-oidc_login

    _kubectl-oidc_login() {
      _kubelogin "$@"
    }

    _kubectl-oidc_login "$@"
  '';

  home.persistence."/persist".directories = [
    ".kube"
    ".talos"
    ".config/omni"
  ];
}
