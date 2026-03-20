{
  config,
  pkgs,
  private,
  ...
}:
{
  imports = [
    ./hardware
  ];

  # Host-specific programs
  programs = {
    # Needed for remote vscode
    nix-ld.enable = true;
    # SMTP client -- used by zed for email alerts for zfs array
    msmtp = {
      enable = true;
      accounts = {
        default = {
          auth = false;
          host = "localhost";
          port = 2525;
          from = "argon@nitron.app";
          user = "argon@nitron.app";
        };
      };
    };
  };

  # Host-specific services
  services = {
    # NFS server for serving media
    nfs.server = {
      enable = true;
      exports = ''
        /mnt/vault/media 192.168.20.11(rw,insecure,async,no_subtree_check,all_squash,anonuid=995,anongid=131,fsid=111)
      '';
      createMountPoints = true;
    };
    zfs = {
      autoScrub.enable = true;
      # Emails sent to healthchecks
      zed = {
        enableMail = true;
        settings = {
          ZED_DEBUG_LOG = "/tmp/zed.debug.log";
          ZED_EMAIL_ADDR = [ "ca2d11ca-98fd-47cf-ace0-0a24184095e0@ping.nitron.app" ];
          ZED_EMAIL_PROG = "${pkgs.msmtp}/bin/msmtp";
          ZED_NOTIFY_DATA = true;
          ZED_NOTIFY_VERBOSE = true;
        };
      };
    };
  };

  # Custom module settings
  custom = {
    profiles.base.enable = true;
    profiles.server.enable = true;
    system = {
      shell.aliases = {
        flinks = "find . -links 1 -type f ! -name '*.png' ! -name '*.jpg' ! -name '*sample*' ! -name '*.nfo' ! -name '*.srt'";
        dcp = "docker compose";
        dcu = "docker compose up -d";
        dcs = "docker compose stop";
        dcl = "docker compose logs";
        dut = "COLORTERM=truecolor duf -only-mp /mnt/data-disks/\\*,/mnt/cache-disks/\\*,/mnt/parity-disks/\\*,/mnt/vault";
      };
      docker = {
        enable = true;
        customUser = "docker";
        customUserGroups = [
          "render"
          "video"
        ];
      };
      impermanence = {
        enable = true;
        rootFilesystem = "/dev/disk/by-partlabel/disk-main-root";
        persistPath = "/persist";
        directories = [
          "/etc/exports.d" # zfs mounts
          "/var/lib/docker" # docker storage
        ];
        files = [
          "/etc/zfs/zpool.cache"
        ];
      };
    };
    services = {
      healthchecks = {
        enable = true;
        targetUrl = "https://healthchecks.${private.domain}";
      };
      komodo = {
        enable = true;
        ferretVersion = "1.24.1";
        envFiles = [ config.sops.secrets.komodo.path ];
        core = {
          version = "1.19.5";
        };
        periphery = {
          version = "1.19.5";
        };
        postgres = {
          version = "17.5";
          mountDir = "/mnt/arrays/tank/databases/komodo";
        };
      };
      forgejo-ssh = {
        enable = true;
        sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIUp5CycMjxyBJEIw9awQ38r/BpRRBLixmltEzZb5xK6 Gitea Host Key";
      };
      beszel = {
        # Adding some additional options for the beszel module to show additional disks
        environment = {
          EXTRA_FILESYSTEMS = "sda1__Backups,sdb1__Data3,sdc1__Data1,sdd1__Parity1,sde1__Data2,nvme3n1p1__Cache";
          EXCLUDE_SMART = "true";
        };
      };
      scrutiny = {
        enable = true;
      };
      sanoid = {
        enable = true;
        datasets = [
          "tank/container-configs"
          "tank/databases"
          "tank/immich-media"
          "tank/paperless-data"
          "tank/taylor-drive"
        ];
      };
      snapraid = {
        enable = true;
        healthcheck = "3b23ca50-133a-4d22-84ca-6a383db45eda";
        dataDisks = [
          "/mnt/data-disks/data01"
          "/mnt/data-disks/data02"
          "/mnt/data-disks/data03"
        ];
        contentFiles = [
          "/persist/var/snapraid/snapraid.content"
          "/mnt/snapraid-content/disk01/snapraid.content"
          "/mnt/snapraid-content/disk02/snapraid.content"
          "/mnt/snapraid-content/disk03/snapraid.content"
        ];
        parityFiles = [
          "/mnt/parity-disks/parity01/snapraid.parity"
        ];
      };
      dbdump = {
        enable = true;
        databases = [
          "auth"
          "gatus"
          "netronome"
          "forgejo"
          "mealie"
          "paperless"
          "komodo"
          "miniflux"
          "immich"
          "qui"
          "tracearr"
          "zipline"
        ];
        backupDir = "/mnt/arrays/tank/database-backup";
        time = "00:00";
        keepUntil = 10;
      };
      restic = {
        enable = true;
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
      cachemover = {
        enable = true;
        cacheMount = "/mnt/cache-disks/cache01";
        coldStorage = "/mnt/vault-cold";
        thresholdPercent = 70;
        targetPercent = 30;
        healthcheck = "628b7d91-9767-4ba2-9021-2893105e07f4";
        credentials = {
          NOTIFICATION_URLS = config.sops.secrets."cachemover/discordurl".path;
        };
      };
    };
  };

  # SOPS secrets definitions for host
  # Beszel
  sops.secrets."beszel/sshkey" = { };
  sops.secrets."beszel/argontoken" = { };
  sops.templates."beszel-agent".content = ''
    HUB_URL=https://beszel.${private.domain}
    KEY=${config.sops.placeholder."beszel/sshkey"}
    TOKEN=${config.sops.placeholder."beszel/argontoken"}
    EXTRA_FILESYSTEMS="sda1__Backups,sdb1__Data3,sdc1__Data1,sdd1__Parity1,sde1__Data2,nvme3n1p1__Cache"
    EXCLUDE_SMART=true
  '';
  # Komodo
  sops.secrets.komodo = {
    format = "dotenv";
    sopsFile = ../../secrets/komodo.env;
  };
  # Cachemover
  # sops.secrets."cachemover/apikey" = {
  #   owner = "docker";
  # };
  sops.secrets."cachemover/discordurl" = { };
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
}
