{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  tree-sitter,
}:
rustPlatform.buildRustPackage {
  pname = "worktrunk";
  version = "0.29.0";

  src = fetchFromGitHub {
    owner = "max-sixty";
    repo = "worktrunk";
    rev = "v0.29.0";
    hash = "sha256-JawxnNoEv8ZDLaZmOlMrvsa/cEzmOFYv7oHWmPeOIbc=";
  };

  cargoHash = "sha256-aEUnR3Dk3LFo3vJf+k550YiP3pSN6a7175d91yEned0=";

  nativeBuildInputs = [pkg-config];

  buildInputs = [tree-sitter];

  env = {
    VERGEN_IDEMPOTENT = "1";
    VERGEN_GIT_DESCRIBE = "v0.29.0";
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
