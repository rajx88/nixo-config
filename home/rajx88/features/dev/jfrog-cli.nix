{pkgs, ...}: {
  home.packages = with pkgs; [
    jfrog-cli
  ];

  # jf writes local CLI state here (version-check cache, and any server
  # configs from `jf c add`) even without persistent server config in use.
  home.persistence."/persist".directories = [".jfrog"];
}
