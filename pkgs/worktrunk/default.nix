{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  tree-sitter,
}:
rustPlatform.buildRustPackage {
  pname = "worktrunk";
  version = "0.61.0";

  src = fetchFromGitHub {
    owner = "max-sixty";
    repo = "worktrunk";
    rev = "v0.61.0";
    hash = "sha256-jyj9e1E9wPxcMuWl3/nDrPTh68yNRuxMOEFmvjE3dRk=";
  };

  cargoHash = "sha256-iKOLHyY28CXPAdPmjVocoubOVKPoBTqA/NJ522cC8+o=";

  nativeBuildInputs = [pkg-config];

  buildInputs = [tree-sitter];

  env = {
    VERGEN_IDEMPOTENT = "1";
    VERGEN_GIT_DESCRIBE = "v0.61.0";
  };

  # Tests require snapshot files (insta) not included in release
  doCheck = false;

  meta = with lib; {
    description = "A CLI for Git worktree management, designed for parallel AI agent workflows";
    homepage = "https://github.com/max-sixty/worktrunk";
    license = with licenses; [mit asl20];
    mainProgram = "wt";
  };
}
