{
  config,
  lib,
  ...
}:
let
  cfg = config.custom.programs.thunderbird;

  inherit (lib)
    mkEnableOption
    mkIf
    ;
in
{
  options.custom.programs.thunderbird = {
    enable = mkEnableOption "Enable Thunderbird";
  };

  config = mkIf cfg.enable {
    programs.thunderbird = {
      enable = true;
      # Custom policies to disable things in firefox declaratively
      policies = {
        DisableMasterPasswordCreation = true;
        DisableTelemetry = true;
      };
    };
  };
}
