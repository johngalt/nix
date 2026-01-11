{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.custom.profiles.development;

  inherit (lib)
    mkEnableOption
    mkIf
    ;
in
{
  options.custom.profiles.development = {
    enable = mkEnableOption "Enable development modules";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      devenv
    ];
    programs.direnv = {
      enable = true;
      silent = true;
    };
  };
}
