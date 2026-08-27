{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  tree-sitter,
}:
rustPlatform.buildRustPackage {
  pname = "worktrunk";
  version = "0.75.0";

  src = fetchFromGitHub {
    owner = "max-sixty";
    repo = "worktrunk";
    rev = "v0.75.0";
    hash = "sha256-jOk8m+LTwSZT5wbRJNZF/HWwgQn1bDF97Gm5upF3TnA=";
  };

  cargoHash = "sha256-A32PgFFWS2E/OJQKXvTR9w3nO7dCX5HVXf2Wa/8Sl3k=";

  nativeBuildInputs = [pkg-config];

  buildInputs = [tree-sitter];

  env = {
    VERGEN_IDEMPOTENT = "1";
    VERGEN_GIT_DESCRIBE = "v0.75.0";
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
