{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.system.printing;
  inherit (lib)
    mkEnableOption
    mkIf
    ;
in
{
  options.custom.system.printing = {
    enable = mkEnableOption "Enable standard configuration for printing support";
  };

  config = mkIf cfg.enable {
    services = {
      printing.enable = true;
      printing.drivers = [ pkgs.brlaser ];
      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };
    };
  };
}
