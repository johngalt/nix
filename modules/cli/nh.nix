{
  lib,
  config,
  ...
}:
let
  cfg = config.custom.cli.nh;
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    ;
  inherit (lib.types)
    str
    ;
in
{
  options.custom.cli.nh = {
    enable = mkEnableOption "Enable Yet Another Nix CLI Helper";
    flake = mkOption {
      type = str;
      description = "Location of flake for nh-related flake commands";
      default = "";
    };
  };

  config = mkIf cfg.enable {
    programs = {
      nh = {
        enable = true;
        flake = cfg.flake;
      };
    };
  };
}
