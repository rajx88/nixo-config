{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  tree-sitter,
}:
rustPlatform.buildRustPackage {
  pname = "worktrunk";
  version = "0.29.4";

  src = fetchFromGitHub {
    owner = "max-sixty";
    repo = "worktrunk";
    rev = "v0.29.4";
    hash = "sha256-qNk/1C6cGxESCCKU52CL6pZ7bfVZw8ajdBjqI2k0R8o=";
  };

  cargoHash = "sha256-uhvtdry2WyN/ir2t4MctpGQ60O439WNYi6scF3xkGfE=";

  nativeBuildInputs = [pkg-config];

  buildInputs = [tree-sitter];

  env = {
    VERGEN_IDEMPOTENT = "1";
    VERGEN_GIT_DESCRIBE = "v0.29.4";
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
