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
          "size=2G"
          "mode=755"
        ];
      };
    };
    disk = {
      root = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-SHPP41-1000GM_ANDAN55941140B566";
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
                mountOptions = [ "umask=0077" ];
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
              size = "16G";
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
          "docker" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/var/lib/docker";
              atime = "off";
            };
            mountpoint = "/var/lib/docker";
          };
          "log" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/var/log";
              atime = "off";
            };
            mountpoint = "/var/log";
          };
          "containers" = {
            type = "zfs_fs";
            options.mountpoint = "/opt/docker";
            mountpoint = "/opt/docker";
          };
          "databases" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/opt/databases";
              recordsize = "8K";
              primarycache = "metadata";
            };
          };
        };
      };
    };
  };
}

