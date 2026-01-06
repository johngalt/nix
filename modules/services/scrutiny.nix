{
  config,
  lib,
  ...
}:
let 
  cfg = config.custom.services.scrutiny;
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
  options.custom.services.scrutiny = {
    enable = mkEnableOption "Enable scrutiny collector for disk monitoring";
    endpoint = mkOption {
      type = str;
      description = "Hub endpoint for scrutiny";
      default = "";
    };
    schedule = mkOption {
      type = str;
      description = "Time to start scrutiny collector";
      default = "04:00";
    };
    hostname = mkOption {
      type = str;
      description = "Hostname used for scrutiny collector";
      default = config.networking.hostName;
    };
  };

  config = mkIf cfg.enable {
    services.scrutiny.collector = {
      enable = true;
      schedule = cfg.schedule;
      settings.api.endpoint = cfg.endpoint;
      settings.host.id = cfg.hostname;
    };
  };
}
