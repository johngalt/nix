{
  config,
  pkgs,
  lib,
  ...
}:
let 
  cfg = config.custom.desktop.niri;

  inherit (lib)
    mkIf
    ;
in 
{
  config = mkIf cfg.enable {
    # Set QT apps to follow qt6ct theme settings by default    
    environment.variables = {
      QT_QPA_PLATFORMTHEME = "qt6ct";
      QT_QPA_PLATFORMTHEME_QT6 = "qt6ct";
    };

    environment.systemPackages = with pkgs; [
      # KDE/QT Package dependencies for DMS/Noctalia
      # NixOS and QT doesn't play well on non-Plasma setups
      # Ideally I would use the qt6ct-kde patched package from AUR if I was on Arch
      libsForQt5.qt5ct
      kdePackages.qt6ct
      kdePackages.kcolorscheme
      kdePackages.breeze
      kdePackages.breeze.qt5

      # Theme stuff
      # For KDE Apps (dolphin) need to change Configure -> Window Color Scheme
      adw-gtk3 # Support dynamic theming for gtk3 applications
      (papirus-icon-theme.override {
        color = "blue";
      })

      # For firefox theming
      pywalfox-native
    ];
    # gsettings uses dconf to store settings -- set default icon pack
    # i'm sure there is a way to get ~/.config/gtk-{3,4}.0/settings.ini to work but its not on Nix
    programs.dconf.profiles.user.databases = [
      {
        settings = {
          "org/gnome/desktop/interface" = {
            icon-theme = "Papirus-Dark";
          };
        };
      }
    ];
  };
}
