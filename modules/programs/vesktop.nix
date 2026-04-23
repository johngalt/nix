{ ... }:
{
  flake.modules.nixos.vesktop =
    { pkgs, lib, ... }:
    {
      hj = {
        packages = with pkgs; [ vesktop ];
        files.".config/vesktop/settings.json" = {
          generator = lib.generators.toJSON { };
          value = {
            appBadge = false;
            arRPC = true;
            checkUpdates = false;
            customTitleBar = true;
            disableMinSize = false;
            minimizeToTray = true;
            clickTrayToShowHide = true;
            tray = true;
            enableSplashScreen = true;
            splashTheming = true;
            staticTitle = false;
            hardwareAcceleration = true;
            discordBranch = "stable";
          };
        };
      };

      # Set home files to persist if enabled
      custom.system.impermanence.persistHome = {
        directories = [
          ".config/vesktop"
        ];
      };
    };
}
