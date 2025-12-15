{
  config,
  lib,
  ...
}:
let 
  cfg = config.custom.programs.kitty;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    mkMerge
    ;
  inherit (lib.types)
    attrs
    ;
in 
{
  options.custom.programs.kitty = {
    enable = mkEnableOption "Enable kitty terminal";
    settings = mkOption {
      type = attrs;
      description = "Additional settings to pass to kitty module";
      default = { };
    };
  };

  config = mkIf cfg.enable {
    custom.hjem.cfg = {
      rum.programs.kitty = {
        enable = true;
        integrations.zsh.enable = true;
        settings = mkMerge [
          {
            # Global settings
          }
          cfg.settings
        ];
      };
    };
  };
}
