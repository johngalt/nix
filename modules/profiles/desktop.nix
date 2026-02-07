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
          calibre
          moonlight-qt
          vlc
          localsend
          obsidian
          gpu-screen-recorder-gtk
          rustdesk-flutter
          readest # Ebooks
          imv # image viewer
          papers # Gnome pdf viewer
          zathura # Minimal pdf viewer
          ripdrag
        ];
      };
      # Enable common graphical configurations and environments
      graphical = {
        enable = true;
        portals.enable = true;
        greeter = {
          enable = true; # Disable this if plasma is enabled since plasma uses SDDM
          user = private.username;
        };
        niri.enable = true;
        quickshell = {
          enable = true;
          shell = "dms";
        };
        plasma.enable = false;
      };
      cli = {
        comma.enable = true;
      };
      programs = {
        alacritty = {
          enable = true;
          imports = [ "~/.config/alacritty/dank-theme.toml" ];
        };
        foot = {
          enable = true;
          settings = {
            main.include = "~/.config/foot/dank-colors.ini";
          };
        };
        yazi.enable = true;
        chromium.enable = true;
        firefox.enable = true;
        zen.enable = true;
        discord.enable = true;
        thunderbird.enable = false;
        vscode.enable = true;
        syncthing.enable = true;
        _1password = {
          enable = true;
          polkitUsers = [ "${private.username} " ]; 
        };
        zed.enable = false;
      };
      system = {
        yubikey.enable = true;
        printing.enable = true;
      };
    };
  };
}
