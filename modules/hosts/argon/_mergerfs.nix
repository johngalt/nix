{
  # ROOT FILE SYSTEM IS MANAGED BY DISKO.NIX

  # Disks have data/content btrfs subvolumes to separate snapraid files
  fileSystems."/mnt/data-disks/data01" = {
    device = "/dev/disk/by-uuid/2bad7281-b435-4127-8702-300951adcb6a";
    fsType = "btrfs";
    options = [ "subvol=/data" ];
  };
  fileSystems."/mnt/data-disks/data02" = {
    device = "/dev/disk/by-uuid/a737c66a-0c9a-4dfa-ba46-507dc742efbc";
    fsType = "btrfs";
    options = [ "subvol=/data" ];
  };
  fileSystems."/mnt/data-disks/data03" = {
    device = "/dev/disk/by-uuid/959bd10f-a3f4-4fd4-b641-8d2cbaaafb74";
    fsType = "btrfs";
    options = [ "subvol=/data" ];
  };
  fileSystems."/mnt/cache-disks/cache01" = {
    device = "/dev/disk/by-uuid/24b2e8f6-292c-4790-b8b3-18462b7bb857";
    fsType = "ext4";
  };
  fileSystems."/mnt/parity-disks/parity01" = {
    device = "/dev/disk/by-uuid/3629eee0-f40b-4549-8dbc-ed237c183e06";
    fsType = "btrfs";
  };
  fileSystems."/mnt/snapraid-content/disk01" = {
    device = "/dev/disk/by-uuid/2bad7281-b435-4127-8702-300951adcb6a";
    fsType = "btrfs";
    options = [ "subvol=/content" ];
  };
  fileSystems."/mnt/snapraid-content/disk02" = {
    device = "/dev/disk/by-uuid/a737c66a-0c9a-4dfa-ba46-507dc742efbc";
    fsType = "btrfs";
    options = [ "subvol=/content" ];
  };
  fileSystems."/mnt/snapraid-content/disk03" = {
    device = "/dev/disk/by-uuid/959bd10f-a3f4-4fd4-b641-8d2cbaaafb74";
    fsType = "btrfs";
    options = [ "subvol=/content" ];
  };

  # Backup drive
  fileSystems."/mnt/backups" = {
    device = "/dev/disk/by-uuid/fe72168d-41a8-42aa-a14f-623eaacf1e57";
    fsType = "ext4";
  };

  # MergerFS mount points
  # Vault-cold is mergerfs pool without SSD cache drive
  fileSystems."/mnt/vault-cold" = {
    fsType = "fuse.mergerfs";
    device = "/mnt/data-disks/data*";
    depends = [
      "/mnt/data-disks/data01"
      "/mnt/data-disks/data02"
      "/mnt/data-disks/data03"
    ];
    options = [
      "defaults"
      "nonempty"
      "allow_other"
      "cache.files=off"
      "moveonenospc=true"
      "func.getattr=newest"
      "category.create=pfrd"
      #"category.create=msppfrd" # Most shared path, path-preserving, random percentage of free space
      "ignorepponrename=true" # Needed to allow cross-links from cachemover script to work correctly
      "dropcacheonclose=false"
      "minfreespace=200G"
      "fsname=vault-cold"
    ];
  };
  # Vault is mergerfs pool with SSD cache pool and write first policy
  fileSystems."/mnt/vault" = {
    fsType = "fuse.mergerfs";
    device = "/mnt/cache-disks/cache01:/mnt/data-disks/data*";
    depends = [
      "/mnt/data-disks/data01"
      "/mnt/data-disks/data02"
      "/mnt/data-disks/data03"
      "/mnt/cache-disks/cache01"
    ];
    options = [
      "defaults"
      "nonempty"
      "allow_other"
      "cache.files=off"
      "moveonenospc=true"
      "func.getattr=newest"
      "category.create=ff" # Fill first -- forces new downloads to cache drive
      "dropcacheonclose=false"
      "minfreespace=100G"
      "fsname=vault"
    ];
  };
}
