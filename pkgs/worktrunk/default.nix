{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  tree-sitter,
}:
rustPlatform.buildRustPackage {
  pname = "worktrunk";
  version = "0.47.0";

  src = fetchFromGitHub {
    owner = "max-sixty";
    repo = "worktrunk";
    rev = "v0.47.0";
    hash = "sha256-gN5M/H/O1KRXhw0RJ+tv2Dm4eqmue2QkJOpSNtJJ80k=";
  };

  cargoHash = "sha256-05zbLuF9JeOkm/bC0OpqdHzbz8l7aeZF/xt2jhLIV2M=";

  nativeBuildInputs = [pkg-config];

  buildInputs = [tree-sitter];

  env = {
    VERGEN_IDEMPOTENT = "1";
    VERGEN_GIT_DESCRIBE = "v0.47.0";
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
