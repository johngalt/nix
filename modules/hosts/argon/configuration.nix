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
        preservation
        docker
        ups

        # Service Modules
        dbdump
        restic
        scrutiny
        healthchecks
        komodo-core
        komodo-periphery
        sanoid
        zed
      ];

      # Miscellaneous stuff
      environment.shellAliases = {
        flinks = "find . -links 1 -type f ! -name '*.png' ! -name '*.jpg' ! -name '*sample*' ! -name '*.nfo' ! -name '*.srt'";
        dcp = "docker compose";
        dcu = "docker compose up -d";
        dcs = "docker compose stop";
        dcl = "docker compose logs";
        dut = "COLORTERM=truecolor duf -only-mp /mnt/data-disks/\\*,/mnt/cache-disks/\\*,/mnt/vault";
      };

      # Custom module settings/overrides
      custom = {
        system = {
          # Allow containers to access iGPU
          docker.extraGroups = [ "video" "render" ];
          # Enable server config in ups module
          ups.enableServer = true;
        };
        services = {
          dbdump = {
            databases = [
              "auth"
              "gatus"
              # "netronome"
              "forgejo"
              "mealie"
              "paperless"
              "komodo"
              "miniflux"
              "qui"
              "tracearr"
              "zipline"
            ];
            targetDir = "/mnt/backups/dbdump";
            healthcheckId = "ce8c5b49-50b6-48be-8dc3-cc741c760065";
          };
          # Automated ZFS snapshots
          sanoid.datasets = [
            "tank/containers"
            "tank/databases"
            "tank/photos"
            "tank/paperless"
            "tank/documents"
            "tank/drive"
            "zroot/persist"
            "zroot/home"
          ];
          # Backups via restic
          restic = {
            backupLocations = [
              "/opt/docker" # docker stacks
              "/mnt/backups/dbdump" # postgres databases
              "/mnt/tank/documents" # papra
              "/mnt/tank/paperless" # paperless-ngx
              "/mnt/tank/photos/upload" # immich
              "/mnt/tank/photos/backups"
              "/mnt/tank/drive" # syncthing
              "/mnt/tank/mirror" # contains datasets from other hosts
            ];
            excludePaths = [
              "*.log*"
              "*.log"
              "/opt/docker/plex/**/Cache"
              "/mnt/tank/mirror/**/databases" # will just dump the sql
              "/mnt/tank/mirror/**/.cache"
              "/mnt/tank/mirror/**/.config/vesktop" # why is it so big?
              "/mnt/tank/mirror/**/.config/mozilla"
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
          zed = {
            smtpServer = "localhost";
            fromEmail = "argon@nitron.app";
            toEmail = "ca2d11ca-98fd-47cf-ace0-0a24184095e0@ping.nitron.app";
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
