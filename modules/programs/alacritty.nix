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
    ;
in
{
  options.custom.programs.alacritty = {
    enable = mkEnableOption "Enable alacritty";
    theme = mkOption {
      type = str;
      description = "Theme from alacritty-theme to use";
      default = "catppuccin_macchiato";
    };
  };

  config = mkIf cfg.enable {
    custom.hjem.cfg = {
      packages = [
        pkgs.alacritty-theme
      ];
      rum.programs.alacritty = {
        enable = true;
        # Ugly way to override alacritty-theme option with the dynamic theme from DMS
        settings = {
          general =
            if (cfg.theme == "dank") then
              {
                import = [ "~/.config/alacritty/dank-theme.toml" ];
              }
            else
              {
                import = [ "${pkgs.alacritty-theme}/share/alacritty-theme/${cfg.theme}.toml" ];
              };
          font = {
            size = 11;
            normal = {
              family = "JetBrainsMono NF";
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
