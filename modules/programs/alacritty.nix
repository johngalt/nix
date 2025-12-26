{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.programs.alacritty;

  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    ;
  inherit (lib.types)
    str
    nullOr
    listOf
    ;
in
{
  options.custom.programs.alacritty = {
    enable = mkEnableOption "Enable alacritty";
    theme = mkOption {
      type = nullOr str;
      description = "Theme from alacritty-theme to use";
      default = null;
    };
    imports = mkOption {
      type = listOf str;
      description = "Extra files to import in alacritty config";
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    custom.hjem.cfg = {
      packages = [
        pkgs.alacritty-theme
      ];
      rum.programs.alacritty = {
        enable = true;
        # Set theme from alacritty-theme if defined and merge with list of imports
        settings = {
          general = {
            import = lib.optionals (!isNull cfg.theme) [
              "${pkgs.alacritty-theme}/share/alacritty-theme/${cfg.theme}.toml"
            ] ++ cfg.imports;
          };
          font = {
            size = 11;
            normal = {
              # Pull first default monospace font from fontconfig module
              family = lib.head config.fonts.fontconfig.defaultFonts.monospace;
              style = "Regular";
            };
          };
          window.dimensions = {
            lines = 30;
            columns = 120;
          };
          keyboard.bindings = [
            {
              key = "N";
              mods = "Control";
              action = "CreateNewWindow";
            }
          ];
        };
      };
    };
  };
}
