{ ... }:
{
  flake.modules.nixos.sanoid =
    { config, lib, ... }:
    let
      cfg = config.custom.services.sanoid;

      # Helper function to create attribute set to assign template to each dataset
      templateForSets = lib.genAttrs cfg.datasets (set: {
        useTemplate = [ "backup" ];
      });

      inherit (lib) mkOption;
      inherit (lib.types) listOf str;
    in
    {
      options.custom.services.sanoid = {
        datasets = mkOption {
          type = listOf str;
          description = "List of zfs datasets to run automated snapshots on";
          default = [ "tank" ];
        };
      };

      config = {
        services.sanoid = {
          enable = true;
          templates = {
            backup = {
              hourly = 4;
              daily = 2;
              weekly = 2;
              monthly = 2;
              autosnap = true;
              autoprune = true;
            };
          };
          datasets = templateForSets;
        };
      };
    };
}
