{
  config,
  lib,
  pkgs,
  private,
  ...
}:
let
  cfg = config.custom.cli.git;

  gitName = private.fullname;
  gitEmail = private.email;

  inherit (lib)
    mkEnableOption
    mkIf
    ;
in
{
  options.custom.cli.git = {
    enable = mkEnableOption "Enable Git";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      git
    ];

    custom.hjem.cfg = {
      rum.programs.git = {
        enable = true;
        settings = {
          init = {
            defaultBranch = "main";
          };
          user = {
            email = gitEmail;
            name = gitName;
          };
        };
      };
    };
  };
}
