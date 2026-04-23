# mergerfs-cache-mover by monstermuffin
# https://github.com/monstermuffin/mergerfs-cache-mover
# Moves files off my cache drive to storage pool
{ ... }:
{
  flake.modules.nixos.nas =
    { config, lib, pkgs, ... }:
    let
      moverScript = pkgs.callPackage ../../packages/mergerfs-cache-mover { };
      # ID to use to ping healthchecks service defined in healthchecks module
      healthcheckId = "628b7d91-9767-4ba2-9021-2893105e07f4";
    in
    {
      # Initialize secrets and create config file via template
      sops.secrets."cachemover/discordurl" = { };
      sops.templates."cachemover-config".content = ''
        Paths: 
          CACHE_PATH: "/mnt/cache-disks/cache01"
          BACKING_PATH: "/mnt/vault-cold"
          LOG_PATH: "/tmp/cachemover.log"
        Settings:
          AUTO_UPDATE: false
          THRESHOLD_PERCENTAGE: 70
          TARGET_PERCENTAGE: 30
          MAX_WORKERS: 8
          MAX_LOG_SIZE_MB: 100
          EXCLUDED_DIRS:
            - books
          LOG_LEVEL: "INFO"
          NOTIFICATIONS_ENABLED: true
          NOTIFY_THRESHOLD: true
          NOTIFICATION_URLS:
            - "${config.sops.placeholder."cachemover/discordurl"}"
      '';
      # Systemd service to run the cachemover and ping healthchecks endpoint
      systemd.services.cachemover = {
        description = "Run the cache mover scripts daily";
        startAt = "04:00";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${lib.getExe moverScript} --config ${config.sops.templates."cachemover-config".path} --console-log";
        };
        onFailure = [ "ping-healthchecks@${healthcheckId}:failure.service" ];
        onSuccess = [ "ping-healthchecks@${healthcheckId}:success.service" ];
        wants = [ "ping-healthchecks@${healthcheckId}:start.service" ];
      };
    };
}
