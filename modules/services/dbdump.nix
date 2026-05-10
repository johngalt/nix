{ ... }:
{
  flake.modules.nixos.dbdump =
    { config, lib, pkgs, ... }:
    let
      cfg = config.custom.services.dbdump;
      backupCmd = db:
        "${lib.getExe pkgs.docker} exec -t ${db}-postgres pg_dumpall --clean --if-exists --username=${db} | ${lib.getExe pkgs.gzip} --rsyncable > ${cfg.targetDir}/${db}_$(date +%Y-%m-%d_%H%M%S).sql.gz";
      keepUntil = 10; # Days to keep backups
      runTime = "01:00"; # Time to run the dump

      inherit (lib) mkOption;
      inherit (lib.types) str listOf;
    in
    {
      options.custom.services.dbdump = {
        databases = mkOption {
          type = listOf str;
          description = "List of postgres docker containers to backup";
        };
        targetDir = mkOption {
          type = str;
          description = "Directory to place backup files in";
        };
        healthcheckId = mkOption {
          type = str;
          description = "Healthcheck endpoint to ping";
        };
      };

      config = {
        systemd.services.dbdump = {
          description = "Dump docker stack container databases";
          startAt = runTime;
          script = lib.concatLines (lib.map backupCmd cfg.databases);
          serviceConfig = {
            Type = "oneshot";
          };
          onFailure = [ "ping-healthchecks@${cfg.healthcheckId}:failure.service" ];
          onSuccess = [ "dbdump-cleanup.service" "ping-healthchecks@${cfg.healthcheckId}:success.service" ];
          wants = [ "ping-healthchecks@${cfg.healthcheckId}:start.service" ];
        };

        # Cleanup service to be called after dbdump runs
        systemd.services.dbdump-cleanup = {
          description = "Cleanup old database dumps";
          script = ''
            find ${cfg.targetDir} -type f -name "*.sql.gz" -mtime +${toString keepUntil} -exec rm {} \;
          '';
        };
      };
    };
}
