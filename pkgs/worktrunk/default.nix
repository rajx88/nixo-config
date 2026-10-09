{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  tree-sitter,
}:
rustPlatform.buildRustPackage {
  pname = "worktrunk";
  version = "0.80.0";

  src = fetchFromGitHub {
    owner = "max-sixty";
    repo = "worktrunk";
    rev = "v0.80.0";
    hash = "sha256-wT9V9A6ty4yCp/wJ9F92AC5SrsQzemEb8/d2NSjH/SY=";
  };

  cargoHash = "sha256-CVk7tSdt0eh7MtbbMruU1f4664tlnQPjQ2ovXfRcbIA=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ tree-sitter ];

  env = {
    VERGEN_IDEMPOTENT = "1";
    VERGEN_GIT_DESCRIBE = "v0.80.0";
  };

  # Tests require snapshot files (insta) not included in release
  doCheck = false;

  meta = with lib; {
    description = "A CLI for Git worktree management, designed for parallel AI agent workflows";
    homepage = "https://github.com/max-sixty/worktrunk";
    license = with licenses; [
      mit
      asl20
    ];
    mainProgram = "wt";
  };
}
