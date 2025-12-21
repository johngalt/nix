{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.custom.desktop.plasma;

  inherit (lib)
    mkEnableOption
    mkIf
    ;

in
{
  options.custom.desktop.plasma = {
    enable = mkEnableOption "Enable KDE Plasma";
  };

  config = mkIf cfg.enable {
    services = {
      displayManager = {
        sddm.enable = true;
        sddm.wayland.enable = true;
      };
      desktopManager = {
        plasma6.enable = true;
      };
    };

    environment = {
      variables = {
        # Force HDR support in KDE Plasma since it can't read EDID from monitor
        KWIN_FORCE_ASSUME_HDR_SUPPORT = "1";
      };
      sessionVariables = {
        # Force electron apps to use wayland
        NIXOS_OZONE_WL = "1";
      };
      # Other KDE Packages
      systemPackages = with pkgs.kdePackages; [
        kalk
      ];
    };
  };
}
