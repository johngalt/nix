{
  config,
  lib,
  ...
}:
let
  cfg = config.custom.cli.git;

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
  options.custom.cli.git = {
    enable = mkEnableOption "Enable Git";
    name = mkOption {
      type = str;
      description = "Name for git config";
      default = "";
    };
    email = mkOption {
      type = str;
      description = "Email for git config";
      default = "";
    };
  };

  config = mkIf cfg.enable {
    custom.hjem.cfg = {
      rum.programs.git = {
        enable = true;
        settings = {
          init = {
            defaultBranch = "main";
          };
          user = {
            email = cfg.email;
            name = cfg.name;
          };
        };
      };
    };
  };
}
