{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.custom.services.cachemover;

  moverEnv = {
    CACHE_PATH = cfg.cacheMount;
    BACKING_PATH = cfg.coldStorage;
    LOG_PATH = "/tmp/cachemover.log";
    AUTO_UPDATE = "false";
    THRESHOLD_PERCENTAGE = toString cfg.thresholdPercent;
    TARGET_PERCENTAGE = toString cfg.targetPercent;
    LOG_LEVEL = "INFO";
    MAX_WORKERS = "8";
    MAX_LOG_SIZE_MB = "100";
    EXCLUDED_DIRS = "books"; # comma separated list of directories
    NOTIFICATIONS_ENABLED = lib.boolToString (!isNull cfg.notificationUrl);
    NOTIFY_THRESHOLD = lib.boolToString (!isNull cfg.notificationUrl);
    NOTIFICATION_URLS = cfg.notificationUrl; # comma seperated list of apprise notification endpoints
  };

  inherit (lib)
    mkIf
    mkOption
    mkEnableOption
    ;
  inherit (lib.types)
    nullOr
    str
    int
    ;
in
{
  options.custom.services.cachemover = {
    enable = mkEnableOption "Enable cachemover service to offload cache drive";
    cacheMount = mkOption {
      type = str;
      description = "Mount point for cache drive";
    };
    coldStorage = mkOption {
      type = str;
      description = "Mount point for cold storage pool (without cache drive)";
    };
    thresholdPercent = mkOption {
      type = int;
      description = "Threshold percentage of used space before running cache mover";
      default = 75;
    };
    targetPercent = mkOption {
      type = int;
      description = "Percentage of used space to target when running cache mover";
      default = 30;
    };
    healthcheck = mkOption {
      type = str;
      description = "Healthcheck ID for healthcheck service";
    };
    notificationUrl = mkOption {
      type = nullOr str;
      description = "Apprise URLs to send notifications on cachemover run";
      default = null;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Custom package from ./pkgs folder
      mergerfs-cache-mover
    ];

    systemd.services.cachemover = {
      description = "Run the cache mover scripts daily";
      startAt = "04:00";
      script = ''
        ${pkgs.mergerfs-cache-mover}/bin/mergerfs-cache-mover --console-log
      '';
      serviceConfig = {
        Type = "oneshot";
      };
      environment = moverEnv;
      onFailure = [ "ping-healthchecks@${cfg.healthcheck}:failure.service" ];
      onSuccess = [ "ping-healthchecks@${cfg.healthcheck}:success.service" ];
      wants = [ "ping-healthchecks@${cfg.healthcheck}:start.service" ];
    };
  };
}
