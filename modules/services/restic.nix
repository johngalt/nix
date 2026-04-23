{ ... }: {
  flake.modules.nixos.restic =
    { config, lib, ... }:
    let
      cfg = config.custom.services.restic;

      # Default prune options
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 3"
        "--keep-monthly 3"
      ];
      
      inherit (lib) mkOption mkIf;
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
    # Creating custom options to better handle duplicating backups to multiple repositories
    options.custom.services.restic = {
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

    config = {
      # Will create a duplicate config for each backup location
      services.restic.backups = lib.mapAttrs' (
        name: repo:
        lib.nameValuePair "${name}" {
          passwordFile = repo.passwordFile;
          inherit pruneOpts;
          paths = cfg.backupLocations;
          exclude = cfg.excludePaths;
          repository = mkIf (!isNull repo.location) repo.location;
          timerConfig = {
            OnCalendar = repo.timer;
            Persistent = true;
          };
          environmentFile = mkIf (!isNull repo.environmentFile) repo.environmentFile;
        }
      ) cfg.repositories;

      # Create systemd service to ping healthchecks if a healthcheck ID is defined
      systemd.services = lib.mapAttrs' (
        name: repo:
        lib.optionalAttrs (!isNull repo.healthcheck) (
          lib.nameValuePair "restic-backups-${name}" {
            onFailure = [ "ping-healthchecks@${repo.healthcheck}:failure.service" ];
            onSuccess = [ "ping-healthchecks@${repo.healthcheck}:success.service" ];
            wants = [ "ping-healthchecks@${repo.healthcheck}:start.service" ];
          }
        )
      ) cfg.repositories;
    };
  };
}
