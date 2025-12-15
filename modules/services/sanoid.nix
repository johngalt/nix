{
  config,
  lib,
  ...
}:
let
  cfg = config.custom.services.sanoid;

  template = "backup";
  templateForSets = lib.genAttrs cfg.datasets (set: {
    useTemplate = [ template ];
  });

  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    ;
  inherit (lib.types)
    listOf
    str
    ;
in
{
  options.custom.services.sanoid = {
    enable = mkEnableOption "Enable sanoid automated zfs snapshot tool";
    datasets = mkOption {
      type = listOf str;
      description = "List of zfs datasets to have automated snapshots";
      default = [ "tank" ];
    };
  };

  config = mkIf cfg.enable {
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
}
