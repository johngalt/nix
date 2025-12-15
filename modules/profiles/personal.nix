{
  lib,
  config,
  private,
  pkgs,
  ...
}:
let
  cfg = config.custom.profiles.personal;

  inherit (lib)
    mkEnableOption
    mkIf
    ;
in
{
  options.custom.profiles.personal = {
    enable = mkEnableOption "Enable personal modules";
  };

  config = mkIf cfg.enable {
    # Custom module settings
    custom = {
      hjem = {
        enable = true;
        user = private.username;
        # Extra packages to install for user
        extraPackages = with pkgs; [
          calibre
          moonlight-qt
          just
          vlc
          nixd
          helix
          nixpkgs-track
          duf
          localsend
          obsidian
          vscode
          yazi
        ];
      };
      # Enable common desktop configuration and environments
      desktop = {
        enable = true;
        enableDefaultApps = true;
        dms-greeter = {
          enable = true; # Disable this if plasma is enabled since plasma uses SDDM
          user = private.username;
        };
        niri = {
          enable = true;
          shell = "dms";
        };
        plasma.enable = false;
      };
      programs = {
        alacritty = {
          enable = true;
          theme = "dank";
        };
        chromium.enable = true;
        firefox.enable = true;
        discord.enable = true;
      };
      system = {
        yubikey.enable = true;
        printing.enable = true;
      };
      cli = {
        git = {
          enable = true;
          name = private.fullname;
          email = private.email;
        };
        eza = {
          enable = true;
          theme = "catppuccin";
        };
      };
    };
  };
}
