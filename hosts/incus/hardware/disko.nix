{
  inputs,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.disko # Disko disk management
  ];

  disko.devices = {
    disk = {
      main = {
        device = "/dev/disk/by-id/nvme-SHPP41-1000GM_ANDAN55941140B566";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "500M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
            tank = {
              size = "800G";
              content = {
                type = "zfs";
                pool = "tank";
              };
            };
            swap = {
              size = "100%";
              content = {
                type = "swap";
              };
            };
          };
        };
      };
    };
    zpool = {
      tank = {
        type = "zpool";
        mode = "";
        options = {
          autotrim = "on";
          ashift = "12";
        };
      };
    };
  };
}
