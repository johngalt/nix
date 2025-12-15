{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.services.snapraid;

  snapraidDataDisks = builtins.listToAttrs (
    lib.lists.imap1 (i: d: {
      name = "d${toString i}";
      value = "${d}";
    }) cfg.dataDisks
  );

  snapperConfigs = builtins.listToAttrs (
    builtins.map (d: {
      name = "${builtins.baseNameOf d}";
      value = {
        SUBVOLUME = "${d}";
        FSTYPE = "btrfs";
        TIMELINE_CREATE = false;
        SPACE_LIMIT = "0.5";
        FREE_LIMIT = "0.2";
        SYNC_ACL = "no";
        BACKGROUND_COMPARISON = "yes";
        NUMBER_CLEANUP = "yes";
        NUMBER_MIN_AGE = "3600";
        NUMBER_LIMIT = "50";
        NUMBER_LIMIT_IMPORTANT = "10";
      };
    }) cfg.dataDisks
  );

  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    ;
  inherit (lib.types)
    str
    listOf
    ;
in
{
  options.custom.services.snapraid = {
    enable = mkEnableOption "Enable snapraid+btrfs configuration";
    dataDisks = mkOption {
      type = listOf str;
      description = "List of data disk mount points";
    };
    contentFiles = mkOption {
      type = listOf str;
      description = "List of content file paths";
    };
    parityFiles = mkOption {
      type = listOf str;
      description = "List of parity file paths";
    };
    healthcheck = mkOption {
      type = str;
      description = "ID to ping via healthchecks service on snapraid-btrfs run";
    };
  };

  config = mkIf cfg.enable {
    # Snapraid-btrfs custom packages from ./pkgs directory
    environment.systemPackages = with pkgs; [
      snapraid-btrfs
      snapraid-btrfs-runner
    ];
    services = {
      snapraid = {
        inherit (cfg) contentFiles parityFiles;
        enable = true;
        dataDisks = snapraidDataDisks;
        exclude = [
          "*.unrecoverable"
          "/tmp/"
          "/lost+found/"
          "*.!sync"
          "/.snapshots/"
        ];
        extraConfig = ''
          nohidden
          autosave 500
        '';
      };
      snapper.configs = snapperConfigs;
    };

    # Snapraid-btrfs service
    # Creates btrfs snapshots before running snapraid
    systemd.services.snapraid-btrfs-runner = {
      description = "Run the snapraid-btrfs sync with the runner";
      startAt = "06:00";
      script = ''
        ${pkgs.snapraid-btrfs-runner}/bin/snapraid-btrfs-runner
      '';
      serviceConfig = {
        Type = "oneshot";
      };
      onFailure = [ "ping-healthchecks@${cfg.healthcheck}:failure.service" ];
      onSuccess = [ "ping-healthchecks@${cfg.healthcheck}:success.service" ];
      wants = [ "ping-healthchecks@${cfg.healthcheck}:start.service" ];
    };

    # Disable snapraid module systemd services, since we run snapraid-btrfs runner instead (sync and scrub)
    systemd.services.snapraid-sync.enable = false;
    systemd.services.snapraid-scrub.enable = false;
  };
}
