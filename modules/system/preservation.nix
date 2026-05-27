{ ... }:
{
  flake.modules.nixos.preservation =
    { inputs, lib, config, ... }:
    let
      cfg = config.custom.system.preservation;

      # Global files/directories to make persistent across all hosts
      # Main persist files will be replicated to backup
      # Cache persist will be preserved on host, but not backed up

      commonDirectories = [
        # Common persisted directories
      ]
      ++ lib.optional config.networking.networkmanager.enable "/etc/NetworkManager/system-connections"
      ++ lib.optional config.networking.wireless.iwd.enable "/var/lib/iwd";

      commonCacheDirectories = [
        { directory = "/var/lib/nixos"; inInitrd = true; }
        "/var/lib/systemd/timers"
        "/var/lib/systemd/coredump"
        "/var/lib/systemd/rfkill"
        "/var/lib/logrotate"
      ]
      ++ lib.optional config.services.upower.enable "/var/lib/upower"
      ++ lib.optional config.hardware.bluetooth.enable "/var/lib/bluetooth"
      ++ lib.optional config.services.fwupd.enable "/var/lib/fwupd";

      commonFiles = [
        { file = "/etc/machine-id"; inInitrd = true; }
        { file = "/etc/ssh/ssh_host_rsa_key"; how = "symlink"; configureParent = true; inInitrd = true; }
        { file = "/etc/ssh/ssh_host_ed25519_key"; how = "symlink"; configureParent = true; inInitrd = true; }
      ]
      ++ lib.optionals config.networking.networkmanager.enable [
        "/var/lib/NetworkManager/secret_key"
        "/var/lib/NetworkManager/seen-bssids"
        "/var/lib/NetworkManager/timestamps"
      ];

      commonCacheFiles = [
        # Common persisted cache files
      ]
      ++ lib.optional config.boot.zfs.enabled { file = "/etc/zfs/zpool.cache"; inInitrd = true; };

      inherit (lib) mkOption;
      inherit (lib.types)
        str
        listOf
        anything
        ;
    in
    {
      imports = [ inputs.preservation.nixosModules.default ];

      # Define options to allow for other modules to add files/dirs to be preserved
      options.custom.system.preservation = {
        persistPath = mkOption {
          type = str;
          description = "Directory/subvolume to hold persisted state";
          default = "/persist";
        };
        persistCachePath = mkOption {
          type = str;
          description = "Directory/subvolume to hold persisted cached files";
          default = "/cache";
        };
        extraDirectories = mkOption {
          type = listOf anything;
          description = "List of directories to persist";
          default = [ ];
        };
        extraFiles = mkOption {
          type = listOf anything;
          description = "List of files to persist";
          default = [ ];
        };
        extraCacheDirectories = mkOption {
          type = listOf anything;
          description = "List of directories to persist";
          default = [ ];
        };
        extraCacheFiles = mkOption {
          type = listOf anything;
          description = "List of files to persist";
          default = [ ];
        };
      };

      config = {
        preservation = {
          enable = true;
          preserveAt.${cfg.persistPath} = {
            commonMountOptions = [ "x-gvfs-hide" ];
            files = commonFiles ++ cfg.extraFiles;
            directories = commonDirectories ++ cfg.extraDirectories;
          };
          preserveAt.${cfg.persistCachePath} = {
            commonMountOptions = [ "x-gvfs-hide" ];
            files = commonCacheFiles ++ cfg.extraCacheFiles;
            directories = commonCacheDirectories ++ cfg.extraCacheDirectories;
          };
        };

        # Logrotate file doesn't like pre-existing symlinks..
        # https://github.com/nix-community/impermanence/issues/270
        services.logrotate.extraArgs = lib.mkAfter [ "--state" "/var/lib/logrotate/logrotate.status" ];

        # systemd-machine-id-commit.service fails when /etc/machine-id exists already
        systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];
      };
    };
}
