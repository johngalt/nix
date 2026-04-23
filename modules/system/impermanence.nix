{ ... }:
{
  flake.modules.nixos.impermanence =
    { inputs, lib, config, pkgs, ... }:
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
        anything
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

      # Common home directory folders/files to persist in hosts with this enabled
      commonUserDirectories = [
        "Downloads"
        "Documents"
        "Pictures"
        "Desktop"
        # Sops and ssh require folder permission specification
        { directory = ".ssh"; mode = "0700"; }
        { directory = ".gnupg"; mode = "0700"; }
        { directory = ".pki"; mode = "0700"; }
      ];

    in
    {
      imports = [ inputs.impermanence.nixosModules.impermanence ];

      # Define options to be set/modified by other modules
      options.custom.system.impermanence = {
        rootFilesystem = mkOption {
          type = str;
          description = "Path of root file system to be mounted when running wipe script on boot";
        };
        persistPath = mkOption {
          type = str;
          description = "Root path to hold persisted files/directories";
          default = "/persist";
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
        persistHome = {
          enable = mkEnableOption "Enable home directory impermanence";
          user = mkOption {
            type = str;
            description = "User to persist home directory";
          };
          files = mkOption {
            type = listOf anything;
            description = "List of files (str) to persist in home directory";
            default = [ ];
          };
          directories = mkOption {
            type = listOf anything;
            description = "List of directories (str) to persist in home directory";
            default = [ ];
          };
        };
      };

      config = {
        environment.persistence.${cfg.persistPath} = {
          enable = true;
          hideMounts = true;
          directories = commonDirectories ++ cfg.extraDirectories;
          files = commonFiles ++ cfg.extraFiles;
          users = mkIf cfg.persistHome.enable {
            ${cfg.persistHome.user} = {
              directories = commonUserDirectories ++ cfg.persistHome.directories;
              files = cfg.persistHome.files;
            };
          };
        };

        # Script to wipe root partition with each boot
        # Can't use initrd.postResumeCommands anymore
        # https://github.com/nix-community/impermanence/issues/320
        boot.initrd.systemd = {
          services.impermance-btrfs-rolling-root = {
            description = "Archiving existing BTRFS root subvolume and creating a fresh one";
            # Specify dependencies explicitly
            unitConfig.DefaultDependencies = false;
            # The script needs to run to completion before this service is done
            serviceConfig = {
              Type = "oneshot";
              StandardOutput = "journal+console";
              StandardError = "journal+console";
            };
            # This service is required for boot to succeed
            requiredBy = ["initrd.target"];
            # Should complete before any file systems are mounted
            before = ["sysroot.mount"];

            # Wait until the root device is available
            # If you're altering a different device, specify its device unit explicitly.
            requires = ["initrd-root-device.target"];
            after = [
              "initrd-root-device.target"
              # Allow hibernation to resume before trying to alter any data
              "local-fs-pre.target"
            ];

            # The body of the script. Make your changes to data here
            script = ''
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
          extraBin = {
            "mkdir" = "${pkgs.coreutils}/bin/mkdir";
            "date" = "${pkgs.coreutils}/bin/date";
            "stat" = "${pkgs.coreutils}/bin/stat";
            "mv" = "${pkgs.coreutils}/bin/mv";
            "find" = "${pkgs.findutils}/bin/find";
            "btrfs" = "${pkgs.btrfs-progs}/bin/btrfs";
          }; 
        };
      };
    };
}
