{ ... }:
{
  flake.modules.nixos.sanoid =
    { config, lib, pkgs, ... }:
    let
      cfg = config.custom.services.sanoid;

      # Helper function to create attribute set to assign template to each dataset
      templateForSets = template: (datasets: lib.genAttrs datasets (set: {
        useTemplate = [ template ];
        recursive = cfg.setRecursive;
      }));

      inherit (lib) mkOption;
      inherit (lib.types) listOf str bool;
    in
    {
      options.custom.services.sanoid = {
        datasets = mkOption {
          type = listOf str;
          description = "List of zfs datasets to run automated snapshots on";
          default = [ "tank" ];
        };
        ignoreSets = mkOption {
          type = listOf str;
          description = "List of children zfs datasets to ignore";
          default = [ ];
        };
        setRecursive = mkOption {
          type = bool;
          description = "Whether to pass recursive flag to sanoid for each dataset";
          default = false;
        };
      };

      config = {
        environment.systemPackages = with pkgs; [
          sanoid
        ];

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
            ignore = {
              hourly = 0;
              daily = 0;
              weekly = 0;
              monthly = 0;
              autosnap = false;
              autoprune = false;
            };
          };
          datasets =
            (templateForSets "backup" cfg.datasets)
            // (templateForSets "ignore" cfg.ignoreSets);
        };
      };
    };
}
