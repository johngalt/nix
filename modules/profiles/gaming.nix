{
  lib,
  config,
  ...
}:
let
  cfg = config.custom.profiles.gaming;

  inherit (lib)
    mkEnableOption
    mkIf
    ;
in
{
  options.custom.profiles.gaming = {
    enable = mkEnableOption "Enable gaming modules";
  };

  config = mkIf cfg.enable {
    custom.programs.steam.enable = true;
  };
}
