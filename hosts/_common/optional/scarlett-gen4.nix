{ pkgs, ... }: {
  # The Scarlett's onboard mixer/gain state is not persisted by NixOS and can
  # silently reset (e.g. after the interface is power-cycled on the dock),
  # leaving the mic input effectively at zero gain. Re-apply it on every boot.
  systemd.services.scarlett-gen4-mixer = {
    description = "Apply Focusrite Scarlett 2i2 4th Gen input settings";
    wantedBy = [ "multi-user.target" ];
    after = [ "sound.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      AMIXER=${pkgs.alsa-utils}/bin/amixer
      # Interface is hot-plugged (USB, behind the dock): wait for the card.
      for _ in $(${pkgs.coreutils}/bin/seq 1 30); do
        $AMIXER -c Gen scontrols >/dev/null 2>&1 && break
        ${pkgs.coreutils}/bin/sleep 1
      done
      # Rode PodMic is a dynamic mic: no phantom power.
      $AMIXER -c Gen cset name="Line In 1-2 Phantom Power Capture Switch" off
      # Input 1 (PodMic): line/mic level, and enough gain for a low-output dynamic.
      $AMIXER -c Gen cset name="Line In 1 Level Capture Enum" Line
      $AMIXER -c Gen cset name="Line In 1 Gain Capture Volume" 66
    '';
  };
}
