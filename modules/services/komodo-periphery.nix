{ ... }:
{
  flake.modules.nixos.komodo-periphery =
    { pkgs, lib, config, private, hostConfig, ... }:
    let
      cfg = config.custom.services.komodo-periphery;

      # Will use own komodo package until it gets updated in nixpkgs
      komodoPackage = pkgs.callPackage ../../packages/komodo { };

      # Lets use nix to generate a config file for komodo-periphery
      settingsFormat = pkgs.formats.toml { }; 
      # Standard config for periphery
      baseSettings = {
        core_address = "http://192.168.10.10:9120";
        connect_as = hostConfig.name;
        root_directory = "/var/lib/komodo-periphery";
        stack_dir = "/opt/docker";
      };
      # Merge base settings with optional onboarding key into final toml config file
      configFile = settingsFormat.generate "komodo-periphery.toml" (
        baseSettings
        // { onboarding_key = cfg.onboardingKey; }
      );

      inherit (lib) mkOption;
      inherit (lib.types) str package;
    in
    {
      options.custom.services.komodo-periphery = {
        # Can change this once nixpkgs updates komodo 
        package = mkOption {
          type = package;
          description = "Package to use for komodo";
          default = komodoPackage;
        };
        onboardingKey = mkOption {
          type = str;
          description = "Key to onboard komodo-periphery -- only needed for initial setup";
          default = "";
        };
        user = mkOption {
          type = str;
          description = "User to use for komodo-periphery";
          default = "komodo-periphery";
        };
        group = mkOption {
          type = str;
          description = "Group to use for komodo-periphery";
          default = "komodo-periphery";
        };
      };

      config = {
        # Enable docker if it isn't already
        virtualisation.docker.enable = true;

        # Create komodo-periphery user
        users.users.${cfg.user} = {
          isSystemUser = true;
          group = cfg.group;
          description = "Komodo Periphery service user";
          home = baseSettings.root_directory;
          extraGroups = [ "docker" ];
        };
        users.groups.${cfg.group} = { };

        # Create the system folders for the service
        systemd.tmpfiles.settings."10-komodo-periphery" = {
          "${baseSettings.root_directory}".d = {
            mode = "0755";
            user = cfg.user;
            group = cfg.group;
          };
          "${baseSettings.root_directory}/repos".d = {
            mode = "0755";
            user = cfg.user;
            group = cfg.group;
          };
          "${baseSettings.root_directory}/ssl".d = {
            mode = "0700";
            user = cfg.user;
            group = cfg.group;
          };
          "${baseSettings.root_directory}/keys".d = {
            mode = "0700";
            user = cfg.user;
            group = cfg.group;
          };
          "${baseSettings.root_directory}/builds".d = {
            mode = "0755";
            user = cfg.user;
            group = cfg.group;
          };
          # Create empty directory for docker builds
          "/var/empty/.docker".d = {
            mode = "0755";
            user = cfg.user;
            group = cfg.group;
          };
        };

        # Create the systemd service to run the periphery agent
        systemd.services.komodo-periphery = {
          description = "Komodo Periphery - Multi-server Docker and Git deployment agent";
          after = [
            "network-online.target"
            "docker.service"
          ];
          wants = [
            "network-online.target"
            "docker.service"
          ];
          wantedBy = [ "multi-user.target" ];

          serviceConfig = {
            Type = "simple";
            User = cfg.user;
            Group = cfg.group;
            SupplementaryGroups = [ "docker" ];
            Restart = "on-failure";
            RestartSec = "10s";
            WorkingDirectory = baseSettings.root_directory;

            ExecStart = lib.escapeShellArgs [
              "${lib.getExe' cfg.package "periphery"}"
              "--config-path"
              configFile
            ];

            Environment = lib.mapAttrsToList (name: value: "${name}=${value}") {
              PATH = "/run/current-system/sw/bin:/run/wrappers/bin";
            };
            
            StateDirectory = "komodo-periphery";
            StateDirectoryMode = "0755";

            NoNewPrivileges = true;
            PrivateTmp = true;
            ProtectSystem = "full";
            ProtectHome = true;
          };
        };
      };
    };
}
