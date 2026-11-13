# Build a zsh completion file at build time so a shell never has to spawn the
# CLI (some are heavy) just to initialise completion. HOME must be writable:
# opencode, copilot and omp create cache directories while generating.
#
# Packages that already ship a zsh completion are left alone: their file is
# exposed through the profile's share/zsh and picked up by compinit, so there
# is nothing to generate (and no duplicate-file collision in the profile).
{ pkgs, lib }:
name: pkg: exe: args:
pkgs.runCommandLocal "${name}-zsh-completion" { } ''
  export HOME=$TMPDIR
  mkdir -p $out/share/zsh/site-functions

  if [ ! -e "${pkg}/share/zsh/site-functions/_${name}" ] \
    && [ ! -e "${pkg}/share/zsh/vendor-completions/_${name}" ]; then
    ${lib.getExe' pkg exe} ${args} > $out/share/zsh/site-functions/_${name}
  fi
''
