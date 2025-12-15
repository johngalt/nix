{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.services.dbdump;

  backupCmd =
    db:
    "${lib.getExe pkgs.docker} exec -t ${db}-postgres pg_dumpall --clean --if-exists --username=${db} | ${lib.getExe pkgs.gzip} --rsyncable > ${cfg.backupDir}/${db}_$(date +%Y-%m-%d_%H%M%S).sql.gz";

  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    ;
  inherit (lib.types)
    str
    int
    listOf
    nullOr
    ;
in
{
  options.custom.services.dbdump = {
    enable = mkEnableOption "Enable dbdump script to backup postgres databases";
    databases = mkOption {
      type = listOf str;
      description = "List of stack container databases to backup";
    };
    backupDir = mkOption {
      type = str;
      description = "Location to store database dumps";
    };
    time = mkOption {
      type = str;
      description = "What time to run the database dump script";
      default = "01:00";
    };
    healthcheck = mkOption {
      type = nullOr str;
      description = "Healthcheck ID to ping via healthchecks service";
      default = null;
    };
    keepUntil = mkOption {
      type = int;
      description = "Number of days to keep backups";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.dbdump = {
      description = "Dump docker stack container databases";
      startAt = cfg.time;
      script = lib.concatLines (lib.map backupCmd cfg.databases);
      serviceConfig = {
        Type = "oneshot";
      };
      onSuccess = [ "dbdump-cleanup.service" ];
    }
    // lib.optionalAttrs (!isNull cfg.healthcheck) {
      onFailure = [ "ping-healthchecks@${cfg.healthcheck}:failure.service" ];
      onSuccess = [ "ping-healthchecks@${cfg.healthcheck}:success.service" ];
      wants = [ "ping-healthchecks@${cfg.healthcheck}:start.service" ];
    };

    systemd.services.dbdump-cleanup = {
      description = "Cleanup old database dumps";
      script = ''
        find ${cfg.backupDir} -type f -name "*.sql.gz" -mtime +${toString cfg.keepUntil} -exec rm {} \;
      '';
    };
  };
}
