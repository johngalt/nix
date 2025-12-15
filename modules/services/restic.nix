{
  config,
  lib,
  ...
}:
let
  cfg = config.custom.services.restic;

  pruneOpts = [
    "--keep-daily 7"
    "--keep-weekly 3"
    "--keep-monthly 3"
  ];

  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    ;
  inherit (lib.types)
    str
    path
    listOf
    attrsOf
    submodule
    nullOr
    ;
in
{
  options.custom.services.restic = {
    enable = mkEnableOption "Enable automated backups via restic";
    backupLocations = mkOption {
      type = listOf str;
      description = "List of paths (str) of locations to backup for host";
      default = [ ];
    };
    excludePaths = mkOption {
      type = listOf str;
      description = "List of paths (str) to exclude from backups";
      default = [ ];
    };
    repositories = mkOption {
      description = "Configuration for repository location targets";
      type = attrsOf (submodule {
        options = {
          location = mkOption {
            type = nullOr str;
            description = "Repository path";
            default = null;
          };
          passwordFile = mkOption {
            type = path;
            description = "Path to password file for repository";
          };
          timer = mkOption {
            type = str;
            description = "OnCalendar time for repo backup to run at";
          };
          healthcheck = mkOption {
            type = nullOr str;
            description = "Healthchecks ID for healthchecks service";
            default = null;
          };
          environmentFile = mkOption {
            type = nullOr str;
            description = "Environment file to include for accessing repository";
            default = null;
          };
        };
      });
    };
  };

  config = mkIf cfg.enable {
    services.restic.backups = lib.mapAttrs' (
      name: backup:
      lib.nameValuePair "${name}" {
        passwordFile = backup.passwordFile;
        inherit pruneOpts;
        paths = cfg.backupLocations;
        exclude = cfg.excludePaths;
        repository = mkIf (!isNull backup.location) backup.location;
        timerConfig = {
          OnCalendar = backup.timer;
          Persistent = true;
        };
        environmentFile = mkIf (!isNull backup.environmentFile) backup.environmentFile;
      }
    ) cfg.repositories;

    # Create systemd service to ping healthchecks if a healthcheck ID is defined
    systemd.services = lib.mapAttrs' (
      name: backup:
      lib.optionalAttrs (!isNull backup.healthcheck) (
        lib.nameValuePair "restic-backups-${name}" {
          onFailure = [ "ping-healthchecks@${backup.healthcheck}:failure.service" ];
          onSuccess = [ "ping-healthchecks@${backup.healthcheck}:success.service" ];
          wants = [ "ping-healthchecks@${backup.healthcheck}:start.service" ];
        }
      )
    ) cfg.repositories;
  };
}
