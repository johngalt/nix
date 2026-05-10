{ ... }:
{
  flake.modules.nixos.docker =
    { lib, config, ... }:
    let
      dockerUser = "docker";
      dockerGroup = "docker";

      cfg = config.custom.system.docker;

      inherit (lib) mkOption;
      inherit (lib.types) listOf str;
    in
    {
      options.custom.system.docker = {
        extraGroups = mkOption {
          type = listOf str;
          description = "Extra groups to be added to docker user";
          default = [ ];
        };
      };

      config = {
        virtualisation.docker = {
          enable = true;
          autoPrune.enable = true;
          daemon.settings = {
            # Forces docker to keep bridge networks in the same subnet
            # https://github.com/moby/moby/issues/37823
            default-address-pools = [
              {
                base = "172.17.0.0/16";
                size = 24;
              }
            ];
          };
        };

        # Create a docker user
        users.users.${dockerUser} = {
          isSystemUser = true;
          uid = 995; # makes it easier for setting permissions in docker-compose
          group = dockerGroup;
          extraGroups = cfg.extraGroups;
        };

        users.groups.${dockerGroup} = {
          gid = 131; # makes it easier for setting permissions in docker-compose
        };
      };
    };
}
