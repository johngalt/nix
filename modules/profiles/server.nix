{
  lib,
  config,
  ...
}:
let
  cfg = config.custom.profiles.server;

  inherit (lib)
    mkEnableOption
    mkIf
    ;
in
{
  options.custom.profiles.server = {
    enable = mkEnableOption "Enable general server modules";
  };

  config = mkIf cfg.enable {
    # Custom module settings
    custom = {
      # Beszel
    };
  };
}
