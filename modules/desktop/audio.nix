{
  config,
  lib,
  ...
}:
let
  cfg = config.custom.desktop;
  inherit (lib)
    mkIf
    ;
in
{
  config = mkIf cfg.enable {
    services = {
      pipewire = {
        enable = true;
        pulse.enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        wireplumber.enable = true;
      };
    };
    # Needed for pulse and pipewire
    security.rtkit.enable = true;
  };
}
