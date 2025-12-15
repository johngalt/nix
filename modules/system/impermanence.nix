{
  config,
  inputs,
  lib,
  ...
}:
let
  cfg = config.custom.system.impermanence;
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    ;
  inherit (lib.types)
    str
    listOf
    ;

  # Global files/directories to make persistent across all hosts
  commonDirectories = [
    "/var/lib/nixos"
  ];
  commonFiles = [
    "/etc/machine-id"
    "/etc/ssh/ssh_host_ed25519_key"
    "/etc/ssh/ssh_host_ed25519_key.pub"
    "/etc/ssh/ssh_host_rsa_key"
    "/etc/ssh/ssh_host_rsa_key.pub"
    "/var/lib/logrotate.status"
  ];
in
{
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  options.custom.system.impermanence = {
    enable = mkEnableOption "Enable impermanence for file system";
    rootFilesystem = mkOption {
      type = str;
      description = "Path of root file system to be mounted when running wipe script on boot";
    };
    persistPath = mkOption {
      type = str;
      description = "Root path to hold persisted files/directories";
      default = "/persist";
    };
    directories = mkOption {
      type = listOf str;
      description = "List of directories (str) to persist";
      default = [ ];
    };
    files = mkOption {
      type = listOf str;
      description = "List of files (str) to persist";
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    # Enable and configure persistence
    environment.persistence.${cfg.persistPath} = {
      enable = true;
      hideMounts = true;
      directories = commonDirectories ++ cfg.directories;
      files = commonFiles ++ cfg.files;
    };

    # Set boot script to wipe file system on boot
    boot.initrd.postResumeCommands = lib.mkAfter ''
      mkdir /btrfs_tmp
      mount ${cfg.rootFilesystem} /btrfs_tmp
      if [[ -e /btrfs_tmp/root ]]; then
          mkdir -p /btrfs_tmp/old_roots
          timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
          mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
      fi

      delete_subvolume_recursively() {
          IFS=$'\n'
          for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
              delete_subvolume_recursively "/btrfs_tmp/$i"
          done
          btrfs subvolume delete "$1"
      }

      for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
          delete_subvolume_recursively "$i"
      done

      btrfs subvolume create /btrfs_tmp/root
      umount /btrfs_tmp
    '';
  };
}
