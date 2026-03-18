{
  config,
  lib,
  ...
}:
let 
  cfg = config.custom.cli.helix;
  
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
  options.custom.cli.helix = {
    enable = mkEnableOption "Enable helix configuration";
    theme = mkOption {
      type = str;
      description = "Helix theme to set";
      default = "";
    };
  };

  config = mkIf cfg.enable {
    custom.hjem.cfg = {
      rum.programs.helix = {
        enable = true;
        settings = {
          editor = {
            color-modes = true;
          };
          theme = cfg.theme;
          # Keybinds
          keys.normal = {
            X = "select_line_above";
          };
        };
        languages = {
          language = [
            {
              name = "go";
              auto-format = true;
              formatter = { command = "goimports"; };
            }
          ];
          language-server = {
            gopls = {
              command = "gopls";
              args = [ "-logfile=/tmp/gopls.log" "serve" ];
              config = { "ui.diagnostic.staticcheck" = true; };
            };
          };
        };
      };
    };
  };
}
