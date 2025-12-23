{
  config,
  lib,
  ...
}:
let 
  cfg = config.custom.programs.foot;
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    mkMerge
    ;
  inherit (lib.types)
    attrs
    ;
in 
{
  options.custom.programs.foot = {
    enable = mkEnableOption "Enable foot terminal";
    settings = mkOption {
      type = attrs;
      description = "Extra settings to pass to foot config";
      default = { };
    };
  };

  config = mkIf cfg.enable {
    programs.foot = {
      enable = true;
    };
    custom.hjem.cfg = {
      rum.programs.foot = {
        enable = true;
        package = null; # Installed globally
        settings = mkMerge [
          {
            # Global module settings
          }
          cfg.settings
        ];
      };
    };
  };
}
