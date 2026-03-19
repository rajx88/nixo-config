{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  perl,
  cmake,
  installShellFiles,
  zlib,
}:
rustPlatform.buildRustPackage {
  pname = "agent-of-empires";
  version = "0.17.0";

  src = fetchFromGitHub {
    owner = "njbrake";
    repo = "agent-of-empires";
    rev = "v0.17.0";
    hash = "sha256-bQLFEsN+dRn86fzvmFpKMjNPMn9Kw9+hXmGh+yhOrUE=";
  };

  cargoHash = "sha256-aIjDKYGcjWuk1VektDhWvFJRWmJtXv+FDx4XYgnDoUU=";

  nativeBuildInputs = [pkg-config perl cmake installShellFiles];

  buildInputs = [zlib];

  # Build only the main binary (workspace has xtask member)
  cargoBuildFlags = ["-p" "agent-of-empires"];

  postInstall = ''
    installShellCompletion --cmd aoe \
      --bash <($out/bin/aoe completion bash) \
      --fish <($out/bin/aoe completion fish) \
      --zsh <($out/bin/aoe completion zsh)
  '';

  # Tests require git and tmux
  doCheck = false;

  meta = with lib; {
    description = "Terminal session manager for AI coding agents";
    homepage = "https://github.com/njbrake/agent-of-empires";
    license = licenses.mit;
    mainProgram = "aoe";
  };
}
