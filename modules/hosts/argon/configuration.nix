{ self, ... }:
{
  flake.modules.nixos."hosts/argon" =
    { config, ... }:
    {
      imports = with self.modules.nixos; [
        # Profiles
        base
        server
        nas

        # System Modules
        impermanence
        docker

        # Service Modules
        restic
        scrutiny
        healthchecks
        komodo-core
        komodo-periphery
        sanoid
        attic
      ];

      # Miscellaneous stuff
      environment.shellAliases = {
        flinks = "find . -links 1 -type f ! -name '*.png' ! -name '*.jpg' ! -name '*sample*' ! -name '*.nfo' ! -name '*.srt'";
        dcp = "docker compose";
        dcu = "docker compose up -d";
        dcs = "docker compose stop";
        dcl = "docker compose logs";
        dut = "COLORTERM=truecolor duf -only-mp /mnt/data-disks/\\*,/mnt/cache-disks/\\*,/mnt/parity-disks/\\*,/mnt/vault";
      };

      # Custom module settings/overrides
      custom = {
        system = {
          impermanence = {
            rootFilesystem = "/dev/disk/by-partlabel/disk-main-root";
            persistPath = "/persist";
            extraDirectories = [
              "/etc/exports.d" # zfs mounts
              "/var/lib/docker" # docker storage
            ];
            extraFiles = [
              "/etc/zfs/zpool.cache"
            ];
          };
          # Allow containers to access iGPU
          docker.extraGroups = [ "video" "render" ];
        };
        services = {
          # Automated ZFS snapshots
          sanoid.datasets = [
            "tank/container-configs"
            "tank/databases"
            "tank/immich-media"
            "tank/paperless-data"
            "tank/taylor-drive"
          ];
          # Backups via restic
          restic = {
            backupLocations = [
              "/opt/docker"
              "/mnt/arrays/tank/database-backup"
              "/mnt/arrays/tank/immich-media/profile"
              "/mnt/arrays/tank/immich-media/upload"
              "/mnt/arrays/tank/paperless-data"
              "/mnt/arrays/tank/taylor-drive"
              "/persist"
            ];
            excludePaths = [
              "*.log*"
              "*.log"
              "/opt/docker/plex/**/Cache"
              "/persist/var/snapraid/*"
              "/persist/var/lib/docker/*"
            ];
            repositories = {
              argon-local = {
                location = "/mnt/backups/restic";
                passwordFile = config.sops.secrets."restic/repokey".path;
                timer = "00:50";
                healthcheck = "f49f2adf-7ca1-45d4-b8d0-c518884f18ec";
              };
              argon-b2 = {
                passwordFile = config.sops.secrets."restic/repokey".path;
                environmentFile = config.sops.templates."backblaze.env".path;
                timer = "01:30";
                healthcheck = "835d0d39-5656-4012-8df1-4167196ca3f3";
              };
            };
          };
        };
      };

      # Initialize secrets
      # Restic
      sops.secrets."restic/repokey" = { };
      sops.secrets."backblaze/keyID" = { };
      sops.secrets."backblaze/applicationKey" = { };
      sops.secrets."backblaze/repository" = { };
      sops.templates."backblaze.env".content = ''
        AWS_ACCESS_KEY_ID=${config.sops.placeholder."backblaze/keyID"}
        AWS_SECRET_ACCESS_KEY=${config.sops.placeholder."backblaze/applicationKey"}
        RESTIC_REPOSITORY=${config.sops.placeholder."backblaze/repository"}
      '';
    };
}
