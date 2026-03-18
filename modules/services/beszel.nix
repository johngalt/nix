{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.services.beszel;

  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    ;
  inherit (lib.types)
    str
    attrsOf
    ;

in
{
  options.custom.services.beszel = {
    enable = mkEnableOption "Enable beszel agent";
    environmentFile = mkOption {
      type = lib.types.path;
      description = "Path to environment file used with beszel-agent service";
    };
    environment = mkOption {
      type = attrsOf str;
      description = "Beszel environmental variables";
      default = { };
    };
  };

  config = mkIf cfg.enable {
    services.beszel.agent = {
      enable = true;
      openFirewall = true;
      smartmon.enable = true;
      environmentFile = cfg.environmentFile;
      environment = cfg.environment;
    };
  };
}
