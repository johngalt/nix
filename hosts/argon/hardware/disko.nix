{
  disko.devices.disk.main = {
    device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_1TB_S59ANM0W621674W";
    type = "disk";
    content = {
      type = "gpt"; # GPT partitioning scheme
      partitions = {
        # EFI Partition
        ESP = {
          priority = 1;
          name = "ESP";
          start = "1M";
          end = "512M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        # Btrfs Root Partition
        root = {
          end = "-24G";
          content = {
            type = "btrfs";
            extraArgs = [ "-f" ];
            subvolumes = {
              "/root" = {
                mountOptions = [
                  "compress=zstd"
                  "subvol=root"
                ];
                mountpoint = "/"; # Root subvolume
              };
              "/persist" = {
                mountOptions = [
                  "compress=zstd"
                  "subvol=persist"
                ];
                mountpoint = "/persist"; # Persistent subvolume
              };
              "/log" = {
                mountOptions = [
                  "compress=zstd"
                  "noatime"
                  "subvol=log"
                ];
                mountpoint = "/var/log";
              };
              "/home" = {
                mountOptions = [
                  "compress=zstd"
                  "subvol=home"
                ];
                mountpoint = "/home";
              };
              "/nix" = {
                mountOptions = [
                  "compress=zstd"
                  "noatime"
                  "subvol=nix"
                ];
                mountpoint = "/nix"; # Nix subvolume
              };
              "/frigate" = {
                mountOptions = [
                  "compress=zstd"
                  "subvol=frigate"
                ];
                mountpoint = "/mnt/frigate";
              };
            };
          };
        };
        swap = {
          size = "24G";
          content = {
            type = "swap";
          };
        };
      };
    };
  };
  fileSystems = {
    "/persist".neededForBoot = true;
    "/var/log".neededForBoot = true;
  };
}
