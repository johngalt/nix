{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.cli.bat;
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    ;
  inherit (lib.types)
    str
    ;
in
{
  options.custom.cli.bat = {
    enable = mkEnableOption "Enable bat, a cat replacement";
    theme = mkOption {
      type = str;
      description = "Theme to use for bat";
      default = "Catppuccin Macchiato";
    };
  };

  config =
    mkIf cfg.enable {
      environment.systemPackages = [ pkgs.bat ];
    }
    // mkIf config.custom.hjem.enable {
      # Enable settings file only if hjem is enabled
      custom.hjem.cfg.files.".config/bat/config".text = ''
        --theme="${cfg.theme}"
        --italic-text=always
      '';
    };
}
