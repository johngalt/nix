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
        virtualisation.docker.enable = true;
        virtualisation.docker.autoPrune.enable = true;

        # Create a docker user
        users.users.${dockerUser} = {
          isSystemUser = true;
          group = dockerGroup;
          extraGroups = cfg.extraGroups;
        };
      };
    };
}
