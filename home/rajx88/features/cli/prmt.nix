{pkgs, ...}: {
  home.packages = with pkgs; [
    prmt
  ];

  programs.zsh = {
    initContent = ''
      setopt PROMPT_SUBST
      PROMPT='$(prmt --shell zsh --code $? " {path:#89dceb} {git:#f9e2af:f: } {time:dim:24hs} \n{ok:#a6e3a1}{fail:#f38ba8} ")'
    '';
  };
}
