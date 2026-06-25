{ ... }:
{
  flake.modules.nixos.syncoid =
    { pkgs, config, lib, private, ... }:
    let
      cfg = config.custom.services.syncoid;

      # Removes the zfs pool name from the dataset string
      trimDataset = ds: lib.concatStringsSep "/" (lib.tail (lib.splitString "/" ds));
      # Create attribute set for each dataset to send
      generateCommands = lib.genAttrs cfg.datasets (set: {
        source = set;
        target = "${cfg.targetHost}:${cfg.targetRoot}/${trimDataset set}";
        # This is really ugly logic...
        service = lib.mkMerge [
          # Only add service config to ping healthcheck if healthcheckId has been defined
          (lib.mkIf (!isNull cfg.healthcheckId)
            # Only add extra systemd service options for FIRST dataset to avoid duplicating healthchecks
            (lib.optionalAttrs (set == (lib.head cfg.datasets)) {
              onFailure = [ "ping-healthchecks@${cfg.healthcheckId}:failure.service" ];
              onSuccess = [ "ping-healthchecks@${cfg.healthcheckId}:success.service" ];
              wants = [ "ping-healthchecks@${cfg.healthcheckId}:start.service" ];
            }))
          # Merge in attributes defined in extraServiceConfig
          { serviceConfig = cfg.serviceConfig; }
        ];
      });

      inherit (lib) mkOption;
      inherit (lib.types) listOf str nullOr anything attrs;

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
          type = nullOr str;
          description = "Healthcheck endpoint to ping with service run (empty to not run)";
          default = null;
        };
        interval = mkOption {
          type = anything; # let syncoid module do the type checking
          description = "OnCalendar timer to run. Set as empty list to disable automatic running";
          default = "*-*-* 00/2:00:00";
        };
        serviceConfig = mkOption {
          type = attrs;
          description = "Extra service config attributes to pass to systemd service files";
          default = { };
        };
      };

      config = {
        environment.systemPackages = with pkgs; [
          sanoid
          mbuffer # Network buffering for zfs send/receive
          zstd # Compression used by zfs send/receive
        ];

        # Pull private ssh key from sops
        sops.secrets."syncoid/sshKey" = {
          owner = "syncoid";
          group = "syncoid";
          mode = "0700";
        };

        # Adding public key for target host verification
        services.openssh.knownHosts = {
          "argon" = {
            hostNames = [ "192.168.10.10" "argon.lan.${private.domain}" ];
            publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAiYEfYEsnr25d2wL9yhMbecWF13/sDCT7fiKASPDKIQ";
          };
        };

        services.syncoid = {
          enable = true;
          interval = cfg.interval;
          # Use the syncoid user defined on backup target to handle the zfs send/rcv
          user = "syncoid";
          sshKey = config.sops.secrets."syncoid/sshKey".path;
          commonArgs = [
            "--delete-target-snapshots" # Keep snapshots in sync (so they don't pile up on target)
            "--force-delete" # Removes conflicting snapshots on target
            "--no-privilege-elevation"
            "--compress=zstd-fast"
          ];

          # Uses function in let binding
          commands = generateCommands;
        };
      };
    };
}
