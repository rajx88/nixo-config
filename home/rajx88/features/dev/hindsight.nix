{ lib, ... }: {
  # Central on/off switch for the Hindsight memory backend.
  # Flip default to true here to re-enable everywhere at once.
  options.hindsight.enable = lib.mkEnableOption "Hindsight shared coding-agent memory backend";
}
