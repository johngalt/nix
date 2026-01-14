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
    NOTIFICATIONS_ENABLED = lib.boolToString (lib.hasAttr "NOTIFICATION_URLS" cfg.credentials);
    NOTIFY_THRESHOLD = lib.boolToString (lib.hasAttr "NOTIFICATION_URLS" cfg.credentials);
  };

  inherit (lib)
    mkIf
    mkOption
    mkEnableOption
    ;
  inherit (lib.types)
    attrs
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
    # Hacky way to allow for passing SOPS secrets to systemd script (i.e. notification URL)
    credentials = mkOption {
      type = attrs;
      description = "Credentials to pass to cachemover (e.g. notification URL) as path";
      default = { };
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
        ${lib.concatStringsSep "\n" (
          map (name: ''
            ${name}="$(systemd-creds cat 'SECRET-${name}')"
            export ${name}
          '') (lib.attrNames cfg.credentials)
        )}
        ${pkgs.mergerfs-cache-mover}/bin/mergerfs-cache-mover --console-log
      '';
      serviceConfig = {
        Type = "oneshot";
        LoadCredential = lib.mapAttrsToList (name: value: "SECRET-${name}:${value}") cfg.credentials;
      };
      environment = moverEnv;
      onFailure = [ "ping-healthchecks@${cfg.healthcheck}:failure.service" ];
      onSuccess = [ "ping-healthchecks@${cfg.healthcheck}:success.service" ];
      wants = [ "ping-healthchecks@${cfg.healthcheck}:start.service" ];
    };
  };
}
