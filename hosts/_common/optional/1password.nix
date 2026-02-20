{
  pkgs,
  lib,
  ...
}: {
  # Enable the unfree 1Password packages
  # TODO: check if this can be removed
  # nixpkgs.config.allowUnfreePredicate = pkg:
  #   builtins.elem (lib.getName pkg) [
  #     "1password-gui"
  #     "1password"
  #   ];

  environment.etc = {
    "1password/custom_allowed_browsers" = {
      text = ''
        zen
        zen-beta
      ''; # include both names to support either the unwrapped/stable binary or the beta package
      mode = "0755";
    };
  };

  # this needs to be here to integrate with the browser plugin
  # todo make this conditional for different hosts???
  programs = {
    _1password.enable = true;
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = ["rajx88"];
      # package = pkgs._1password-gui-beta;
    };
  };
}
