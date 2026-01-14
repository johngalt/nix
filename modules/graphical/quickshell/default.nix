{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let 
  cfg = config.custom.graphical.quickshell;
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    ;
  inherit (lib.types)
    enum
    ;
in 
{
  imports = [
    ./dms
    ./noctalia
  ];

  options.custom.graphical.quickshell = {
    enable = mkEnableOption "Enable quickshell module";
    shell = mkOption {
      type = enum [ "dms" "noctalia" ];
      description = "Which quickshell shell to use";
      default = "dms";
    };
  };

  config = mkIf cfg.enable {
    # Overlay from quickshell flake
    # This replaces pkgs.quickshell with one built from quickshell-git
    nixpkgs.overlays = [
      inputs.quickshell.overlays.default
    ];

    # Various settings/packages to support theming for quickshell
    environment.variables = {
      # Set QT apps to follow qt6ct theme settings by default  
      QT_QPA_PLATFORMTHEME = "qt6ct";
      QT_QPA_PLATFORMTHEME_QT6 = "qt6ct";
    };

    environment.systemPackages = with pkgs; [
      # Qt5/6ct for most QT theming
      libsForQt5.qt5ct
      kdePackages.qt6ct
      # KColorScheme used for KDE apps
      kdePackages.kcolorscheme
      # KDE Breeze theme used as base for most QT stuff
      kdePackages.breeze
      kdePackages.breeze.qt5
      # Adw theme for GTK stuff
      adw-gtk3 
      # Papirus icon theme with override for folder color
      (papirus-icon-theme.override {
        color = "green";
      })
      # For firefox theming
      pywalfox-native
    ];
    # Use dconf to force gnome/gtk apps to use different icon theme
    programs.dconf.profiles.user.databases = [
      {
        settings = {
          # Default icon pack
          "org/gnome/desktop/interface" = {
            icon-theme = "Papirus-Dark";
          };
        };
      }
    ];
  };
}
