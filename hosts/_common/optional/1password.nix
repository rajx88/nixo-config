{
  # this needs to be here to integrate with the browser plugin
  # todo make this conditional for different hosts???
  programs = {
    _1password = {
      enable = true;
    };
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = ["rajkoh"];
    };
  };
}
