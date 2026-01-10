{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.services.cachemover;

  moverCmd = builtins.concatStringsSep " " [
    "${pkgs.qbitmover}/bin/qbitmover --host ${cfg.qbitHost}"
    "--cache-mount ${cfg.cacheMount}"
    "--days-from ${toString cfg.daysFrom} --days-to ${toString cfg.daysTo}"
  ];

  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    ;
  inherit (lib.types)
    str
    int
    ;
in
{
  options.custom.services.cachemover = {
    enable = mkEnableOption "Enable cachemover service to offload cache drive";
    user = mkOption {
      type = str;
      description = "User for cachemover systemd service to run as";
      default = "docker";
    };
    qbitHost = mkOption {
      type = str;
      description = "Host for qbittorrent api";
    };
    cacheMount = mkOption {
      type = str;
      description = "Mount point for cache drive";
    };
    coldStorage = mkOption {
      type = str;
      description = "Mount point for cold storage pool (without cache drive)";
    };
    daysTo = mkOption {
      type = int;
      description = "End of range of torrents to move off cache drive";
      default = 30;
    };
    daysFrom = mkOption {
      type = int;
      description = "Beginning of range of torrents to move off cache drive";
      default = 12;
    };
    healthcheck = mkOption {
      type = str;
      description = "Healthcheck ID for healthcheck service";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Custom packages from ./pkgs folder
      qbitmover
      davocache
    ];

    systemd.services.cachemover = {
      description = "Run the cache mover scripts daily";
      startAt = "04:00";
      script = ''
        echo "Pausing torrents ..."
        ${moverCmd} --pause
        echo "Starting cache mover ..."
        ${pkgs.davocache}/bin/davocache ${cfg.cacheMount} ${cfg.coldStorage} ${toString cfg.daysFrom} ${toString cfg.daysTo}
        echo "Resuming torrents ..."
        ${moverCmd} --resume
        echo "Deleting empty directories ..."
        find ${cfg.cacheMount} -type d -empty ! -path '*/books*' ! -path '*/audiobooks*' -delete
        echo "Complete ..."
      '';
      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
      };
      onFailure = [ "ping-healthchecks@${cfg.healthcheck}:failure.service" ];
      onSuccess = [ "ping-healthchecks@${cfg.healthcheck}:success.service" ];
      wants = [ "ping-healthchecks@${cfg.healthcheck}:start.service" ];
    };
  };
}
