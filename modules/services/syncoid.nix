{ ... }:
{
  flake.modules.nixos.syncoid =
    { pkgs, config, lib, ... }:
    let
      cfg = config.custom.services.syncoid;

      interval = "*-*-* 00/2:00:00"; # Every 2 hours

      # Removes the zfs pool name from the dataset string
      trimDataset = ds: lib.concatStringsSep "/" (lib.tail (lib.splitString "/" ds));
      # Create attribute set for each dataset to send
      generateCommands = lib.genAttrs cfg.datasets (set: {
        source = set;
        target = "${cfg.targetHost}:${cfg.targetRoot}/${trimDataset set}";
        # Only add extra systemd service options for FIRST dataset to avoid duplicating healthchecks
        service = lib.optionalAttrs (set == (lib.head cfg.datasets)) {
          onFailure = [ "ping-healthchecks@${cfg.healthcheckId}:failure.service" ];
          onSuccess = [ "ping-healthchecks@${cfg.healthcheckId}:success.service" ];
          wants = [ "ping-healthchecks@${cfg.healthcheckId}:start.service" ];
        };
      });

      inherit (lib) mkOption;
      inherit (lib.types) listOf str;

    in
    {
      options.custom.services.syncoid = {
        datasets = mkOption {
          type = listOf str;
          description = "List of datasets to send";
        };
        targetHost = mkOption {
          type = str;
          description = "Target host to send datasets";
          default = "syncoid@192.168.10.10";
        };
        targetRoot = mkOption {
          type = str;
          description = "Target base dataset on receiving host";
        };
        healthcheckId = mkOption {
          type = str;
          description = "Healthcheck endpoint to ping with service run";
        };
      };

      config = {
        environment.systemPackages = with pkgs; [
          sanoid
          mbuffer # Network buffering for zfs send/receive
          zstd # Compression used by zfs send/receive
        ];

        sops.secrets."syncoid/sshKey" = {
          owner = "syncoid";
          group = "syncoid";
          mode = "0700";
        };

        services.syncoid = {
          enable = true;
          inherit interval;
          user = "syncoid";
          sshKey = config.sops.secrets."syncoid/sshKey".path;
          commonArgs = [
            "--delete-target-snapshots" # Keep snapshots in sync (so they don't pile up on target)
            "--no-privilege-elevation" 
            "--sshoption=\"StrictHostKeyChecking=no\""
            "--compress=zstd-fast"
          ];

          # Uses function in let binding
          commands = generateCommands;
        };
      };
    };
}
