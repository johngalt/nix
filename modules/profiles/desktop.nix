{
  lib,
  config,
  private,
  pkgs,
  ...
}:
let
  cfg = config.custom.profiles.desktop;

  inherit (lib)
    mkEnableOption
    mkIf
    ;
in
{
  options.custom.profiles.desktop = {
    enable = mkEnableOption "Enable desktop modules";
  };

  config = mkIf cfg.enable {
    # Custom module settings
    custom = {
      hjem = {
        # Extra packages to install for user
        extraPackages = with pkgs; [
          calibre # for kindle
	        moonlight-qt
          vlc
          localsend
          obsidian
          gpu-screen-recorder-gtk
          rustdesk-flutter
          readest # ebook reader
          imv # image viewer
          papers # Gnome pdf viewer
          zathura # minimalist pdf viewer
          ripdrag # drag-and-drop from terminal
        ];
      };
      # Enable common graphical configurations and environments
      graphical = {
        enable = true;
        greeter.enable = true;
        niri.enable = true;
        quickshell = {
          enable = true;
          shell = "dms";
        };
      };
      programs = {
        foot.enable = true;
        yazi.enable = true;
        chromium.enable = true;
        firefox.enable = true;
        zen.enable = false;
        discord.enable = true;
        syncthing.enable = true;
        _1password.enable = true;
        zed.enable = true;
      };
      system = {
        yubikey.enable = true;
        printing.enable = true;
      };
    };
  };
}
