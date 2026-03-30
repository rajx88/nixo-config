{pkgs, ...}: {
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # JetBrains Toolbox / IDEs (non-Nix JBR needs these)
      wayland
      libxkbcommon
      libx11
      libxext
      libxrender
      libxtst
      libxi
      libxrandr
      libxcursor
      libxfixes
      libxinerama
      libxcomposite
      libxdamage
      fontconfig
      freetype
      zlib
      libGL
      libdrm
      mesa
      stdenv.cc.cc.lib # libstdc++
    ];
  };

  # Provide /bin/bash for scripts with #!/bin/bash shebangs (e.g. JetBrains Toolbox launchers)
  system.activationScripts.binbash = ''
    mkdir -p /bin
    ln -sfn ${pkgs.bash}/bin/bash /bin/bash
  '';
}
