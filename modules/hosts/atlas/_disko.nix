{
  fileSystems."/persist".neededForBoot = true;
  fileSystems."/cache".neededForBoot = true;
  
  disko.devices = {
    # tmpfs
    nodev = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = [
          "size=1G"
          "mode=755"
        ];
      };
      "/tmp" = {
        fsType = "tmpfs";
        mountOptions = [
          "size=5G"
          "mode=755"
        ];
      };
    };

    # zfs
    disk = {
      root = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-SKHynix_HFS001TEM4X169N_5SE7N806311408A36";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "nofail" "umask=0077" ];
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
            swap = {
              size = "32G";
              content = {
                type = "swap";
              };
            };
          };
        };
      };
    };
    zpool = {
      zroot = {
        type = "zpool";
        rootFsOptions = {
          mountpoint = "none";
          compression = "zstd";
          acltype = "posixacl";
          encryption = "aes-256-gcm";
          keyformat = "passphrase";
          keylocation = "prompt";
          xattr = "sa";
        };
        options = {
          ashift = "12";
          autotrim = "on";
        };
        datasets = {
          "home" = {
            type = "zfs_fs";
            options.mountpoint = "/home";
            mountpoint = "/home";
          };
          "persist" = {
            type = "zfs_fs";
            options.mountpoint = "/persist";
            mountpoint = "/persist";
          };
          "cache" = {
            type = "zfs_fs";
            options.mountpoint = "/cache";
            mountpoint = "/cache";
          };
          "nix" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/nix";
              atime = "off";
            };
            mountpoint = "/nix";
          };
          "log" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/var/log";
              atime = "off";
            };
            mountpoint = "/var/log";
          };
        };
      };
    };
  };
}
