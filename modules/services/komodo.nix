{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.services.komodo;

  # Environmental variables to apply to both komodo-core and komodo-periphery
  # Should probably move these to a module option and define them elsewhere
  commonEnvironment = {
    "KOMODO_DISABLE_CONFIRM_DIALOG" = "true";
    "KOMODO_DISABLE_NON_ADMIN_CREATE" = "false";
    "KOMODO_DISABLE_USER_REGISTRATION" = "true";
    "KOMODO_ENABLE_NEW_USERS" = "false";
    "KOMODO_FIRST_SERVER" = "https://komodo-periphery:8120";
    "KOMODO_GITHUB_OAUTH_ENABLED" = "false";
    "KOMODO_GOOGLE_OAUTH_ENABLED" = "false";
    "KOMODO_JWT_TTL" = "1-day";
    "KOMODO_LOCAL_AUTH" = "true";
    "KOMODO_MONITORING_INTERVAL" = "15-sec";
    "KOMODO_RESOURCE_POLL_INTERVAL" = "5-min";
    "KOMODO_TITLE" = "Komodo";
    "KOMODO_TRANSPARENT_MODE" = "false";
    "PERIPHERY_BUILD_DIR" = "${cfg.periphery.rootDir}/komodo/builds";
    "PERIPHERY_DISABLE_TERMINALS" = "false";
    "PERIPHERY_INCLUDE_DISK_MOUNTS" = "/etc/hostname";
    "PERIPHERY_REPO_DIR" = "${cfg.periphery.rootDir}/komodo/repos";
    "PERIPHERY_ROOT_DIRECTORY" = "${cfg.periphery.rootDir}";
    "PERIPHERY_SSL_ENABLED" = "true";
    "PERIPHERY_STACK_DIR" = "${cfg.periphery.rootDir}";
  };

  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    ;
  inherit (lib.types)
    str
    path
    listOf
    ;
in
{
  options.custom.services.komodo = {
    enable = mkEnableOption "Enable komodo-core and komodo-periphery on host";
    ferretVersion = mkOption {
      type = str;
      description = "Version tag of container image for ferretdb";
      default = "2.7.0";
    };
    envFiles = mkOption {
      type = listOf path;
      description = "Path to environment file to include when running komodo docker stack (core, periphery, postgresql)";
      default = [ ];
    };
    core = {
      version = mkOption {
        type = str;
        description = "Version tag of container image for komodo-core";
        default = "2.0.0";
      };
    };
    periphery = {
      version = mkOption {
        type = str;
        description = "Version tag of container image for komodo-periphery";
        default = "2.0.0";
      };
      rootDir = mkOption {
        type = str;
        description = "Root directory for komodo-periphery to use/mount";
        default = "/opt/docker";
      };
    };
    postgres = {
      version = mkOption {
        type = str;
        description = "Version tag of container image for postgres";
        default = "17-0.107.0";
      };
      mountDir = mkOption {
        type = str;
        description = "Mount point for postgresql container to use for database";
        default = "";
      };
    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.backend = "docker";

    # Containers
    virtualisation.oci-containers.containers."komodo-core" = {
      image = "ghcr.io/moghtech/komodo-core:${cfg.core.version}";
      environment = commonEnvironment;
      environmentFiles = cfg.envFiles;
      volumes = [
        "komodo-repo-cache:/repo-cache:rw"
        "komodo-keys:/config/keys"
      ];
      ports = [
        "9120:9120/tcp"
      ];
      labels = {
        "komodo.skip" = "";
      };
      dependsOn = [
        "komodo-ferretdb"
      ];
      log-driver = "journald";
      extraOptions = [
        "--network-alias=komodo-core"
        "--network=dockernet"
        "--network=komodo"
      ];
    };
    systemd.services."docker-komodo-core" = {
      serviceConfig = {
        Restart = lib.mkOverride 90 "always";
        RestartMaxDelaySec = lib.mkOverride 90 "1m";
        RestartSec = lib.mkOverride 90 "100ms";
        RestartSteps = lib.mkOverride 90 9;
      };
      after = [
        "docker-network-komodo.service"
        "docker-volume-komodo-repo-cache.service"
        "docker-volume-komodo-keys.service"
      ];
      requires = [
        "docker-network-komodo.service"
        "docker-volume-komodo-repo-cache.service"
        "docker-volume-komodo-keys.service"
      ];
      partOf = [
        "docker-compose-komodo-root.target"
      ];
      wantedBy = [
        "docker-compose-komodo-root.target"
      ];
    };
    virtualisation.oci-containers.containers."komodo-ferretdb" = {
      image = "ghcr.io/ferretdb/ferretdb:${cfg.ferretVersion}";
      environmentFiles = cfg.envFiles;
      labels = {
        "komodo.skip" = "";
      };
      dependsOn = [
        "komodo-postgres"
      ];
      volumes = [
        "komodo-ferretdb-state:/state"
      ];
      log-driver = "journald";
      extraOptions = [
        "--network-alias=komodo-ferretdb"
        "--network=komodo"
      ];
    };
    systemd.services."docker-komodo-ferretdb" = {
      serviceConfig = {
        Restart = lib.mkOverride 90 "always";
        RestartMaxDelaySec = lib.mkOverride 90 "1m";
        RestartSec = lib.mkOverride 90 "100ms";
        RestartSteps = lib.mkOverride 90 9;
      };
      after = [
        "docker-network-komodo.service"
      ];
      requires = [
        "docker-network-komodo.service"
      ];
      partOf = [
        "docker-compose-komodo-root.target"
      ];
      wantedBy = [
        "docker-compose-komodo-root.target"
      ];
    };
    virtualisation.oci-containers.containers."komodo-periphery" = {
      image = "ghcr.io/moghtech/komodo-periphery:${cfg.periphery.version}";
      environment = commonEnvironment;
      environmentFiles = cfg.envFiles;
      volumes = [
        "${cfg.periphery.rootDir}:${cfg.periphery.rootDir}:rw"
        "/proc:/proc:rw"
        "/var/run/docker.sock:/var/run/docker.sock:rw"
        "komodo-keys:/config/keys"
      ];
      labels = {
        "komodo.skip" = "";
      };
      log-driver = "journald";
      extraOptions = [
        "--network-alias=komodo-periphery"
        "--network=komodo"
      ];
    };
    systemd.services."docker-komodo-periphery" = {
      serviceConfig = {
        Restart = lib.mkOverride 90 "always";
        RestartMaxDelaySec = lib.mkOverride 90 "1m";
        RestartSec = lib.mkOverride 90 "100ms";
        RestartSteps = lib.mkOverride 90 9;
      };
      after = [
        "docker-network-komodo.service"
        "docker-volume-komodo-keys.service"
      ];
      requires = [
        "docker-network-komodo.service"
        "docker-volume-komodo-keys.service"
      ];
      partOf = [
        "docker-compose-komodo-root.target"
      ];
      wantedBy = [
        "docker-compose-komodo-root.target"
      ];
    };
    virtualisation.oci-containers.containers."komodo-postgres" = {
      image = "ghcr.io/ferretdb/postgres-documentdb:${cfg.postgres.version}-ferretdb-${cfg.ferretVersion}";
      environment = commonEnvironment;
      environmentFiles = cfg.envFiles;
      volumes = [
        "${cfg.postgres.mountDir}:/var/lib/postgresql/data:rw"
      ];
      labels = {
        "komodo.skip" = "";
      };
      log-driver = "journald";
      extraOptions = [
        "--network-alias=komodo-postgres"
        "--network=komodo"
      ];
    };
    systemd.services."docker-komodo-postgres" = {
      serviceConfig = {
        Restart = lib.mkOverride 90 "always";
        RestartMaxDelaySec = lib.mkOverride 90 "1m";
        RestartSec = lib.mkOverride 90 "100ms";
        RestartSteps = lib.mkOverride 90 9;
      };
      after = [
        "docker-network-komodo.service"
      ];
      requires = [
        "docker-network-komodo.service"
      ];
      partOf = [
        "docker-compose-komodo-root.target"
      ];
      wantedBy = [
        "docker-compose-komodo-root.target"
      ];
    };

    # Networks
    systemd.services."docker-network-komodo" = {
      path = [ pkgs.docker ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStop = "docker network rm -f komodo";
      };
      script = ''
        docker network inspect komodo || docker network create komodo
      '';
      partOf = [ "docker-compose-komodo-root.target" ];
      wantedBy = [ "docker-compose-komodo-root.target" ];
    };

    # Volumes
    systemd.services."docker-volume-komodo-repo-cache" = {
      path = [ pkgs.docker ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        docker volume inspect komodo-repo-cache || docker volume create komodo-repo-cache
      '';
      partOf = [ "docker-compose-komodo-root.target" ];
      wantedBy = [ "docker-compose-komodo-root.target" ];
    };
    systemd.services."docker-volume-komodo-keys" = {
      path = [ pkgs.docker ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        docker volume inspect komodo-keys || docker volume create komodo-keys
      '';
      partOf = [ "docker-compose-komodo-root.target" ];
      wantedBy = [ "docker-compose-komodo-root.target" ];
    };
    systemd.services."docker-volume-komodo-ferretdb-state" = {
      path = [ pkgs.docker ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        docker volume inspect komodo-ferretdb-state || docker volume create komodo-ferretdb-state
      '';
      partOf = [ "docker-compose-komodo-root.target" ];
      wantedBy = [ "docker-compose-komodo-root.target" ];
    };

    # Root service
    # When started, this will automatically create all resources and start
    # the containers. When stopped, this will teardown all resources.
    systemd.targets."docker-compose-komodo-root" = {
      unitConfig = {
        Description = "Root target generated by compose2nix.";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
