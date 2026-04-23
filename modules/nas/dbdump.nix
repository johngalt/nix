# Each day will dump databases from various PostgreSQL containers
# Restic will then backup the resulting compressed database dumps
{ ... }:
{
  flake.modules.nixos.nas =
    { lib, pkgs, ... }:
    let
      backupCmd = db:
        "${lib.getExe pkgs.docker} exec -t ${db}-postgres pg_dumpall --clean --if-exists --username=${db} | ${lib.getExe pkgs.gzip} --rsyncable > ${backupDir}/${db}_$(date +%Y-%m-%d_%H%M%S).sql.gz";
      # This assumes that the container is named `NAME-postgres` and the db username is NAME
      databases = [
        "auth"
        "gatus"
        "netronome"
        "forgejo"
        "mealie"
        "paperless"
        "komodo"
        "miniflux"
        "immich"
        "qui"
        "tracearr"
        "zipline"
      ];
      backupDir = "/mnt/arrays/tank/database-backup";
      runTime = "01:00";
      keepUntil = 10; # Days to keep backups
      healthcheckId = "ce8c5b49-50b6-48be-8dc3-cc741c760065";
    in
    {
      systemd.services.dbdump = {
        description = "Dump docker stack container databases";
        startAt = runTime;
        script = lib.concatLines (lib.map backupCmd databases);
        serviceConfig = {
          Type = "oneshot";
        };
        onFailure = [ "ping-healthchecks@${healthcheckId}:failure.service" ];
        onSuccess = [ "dbdump-cleanup.service" "ping-healthchecks@${healthcheckId}:success.service" ];
        wants = [ "ping-healthchecks@${healthcheckId}:start.service" ];
      };

      # Cleanup service to be called after dbdump runs
      systemd.services.dbdump-cleanup = {
        description = "Cleanup old database dumps";
        script = ''
          find ${backupDir} -type f -name "*.sql.gz" -mtime +${toString keepUntil} -exec rm {} \;
        '';
      };
    };
}
