{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.programs.discord;

  inherit (lib)
    mkEnableOption
    mkIf
    ;
in
{
  options.custom.programs.discord = {
    enable = mkEnableOption "Enable Discord (Equibop)";
  };

  config = mkIf cfg.enable {
    custom.hjem.cfg = {
      packages = with pkgs; [ equibop ];
      # files.".config/equibop/settings.json" = {
      #   generator = lib.generators.toJSON { };
      #   value = {
      #     appBadge = false;
      #     arRPC = true;
      #     checkUpdates = false;
      #     customTitleBar = true;
      #     disableMinSize = false;
      #     minimizeToTray = true;
      #     clickTrayToShowHide = true;
      #     tray = true;
      #     enableSplashScreen = true;
      #     splashTheming = true;
      #     # staticTitle = false;
      #     hardwareAcceleration = true;
      #     discordBranch = "stable";
      #   };
      # };
    };
  };
}
