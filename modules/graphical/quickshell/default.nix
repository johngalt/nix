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
    package
    ;
in
{
  options.custom.graphical.quickshell = {
    enable = mkEnableOption "Enable quickshell module";
    shell = mkOption {
      type = enum [ "dms" "noctalia" ];
      description = "Which shell to use";
      default = "dms";
    };
    package = mkOption {
      type = package;
      description = "Quickshell package to use and expose for other modules";
      # Pulling quickshell package from flake instead of using nixpkgs
      default = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default;
    };
  };

  config = mkIf cfg.enable {
    # Various settings/packages to support theming for quickshell

    # System packages to support shells (mainly theming)
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

    # QT THEMING
    # Set environmental variables to force Qt apps to use qt6ct
    environment.variables = {
      # Set QT apps to follow qt6ct theme settings by default
      QT_QPA_PLATFORMTHEME = "qt6ct";
      QT_QPA_PLATFORMTHEME_QT6 = "qt6ct";
    };

    # GTK THEMING
    # Use dconf to force gnome/gtk apps to use custom theme settings
    programs.dconf.profiles.user.databases = [
      {
        settings = {
          # Default icon pack
          "org/gnome/desktop/interface" = {
            icon-theme = "Papirus-Dark"; # Icon pack
            gtk-theme = "adw-gtk3"; # Set adw as gtk3 theme
          };
        };
      }
    ];
  };
}
