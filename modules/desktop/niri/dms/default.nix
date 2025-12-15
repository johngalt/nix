{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.desktop.niri;

  inherit (lib)
    mkIf
    ;
in
{
  imports = [
    inputs.dankMaterialShell.nixosModules.dankMaterialShell
    ./themes # Separated out themes to keep this cleaner
  ];

  config = mkIf (cfg.shell == "dms" && cfg.enable) {
    # Enable DMS
    programs.dankMaterialShell = {
      enable = true;

      systemd = {
        enable = true; # Systemd service for auto-start
        restartIfChanged = true; # Auto-restart dms.service when dankMaterialShell changes
      };

      # Core features
      enableSystemMonitoring = true; # System monitoring widgets (dgop)
      enableVPN = true; # VPN management widget
      enableDynamicTheming = true; # Wallpaper-based theming (matugen)
      enableAudioWavelength = true; # Audio visualizer (cava)
      enableCalendarEvents = true; # Calendar integration (khal)
    };

    # Add additional parameter to systemd service to only start with niri
    systemd.user.services.dms = {
      wants = [ "niri.service" ];
    };

    # Disable niri-flake polkit agent since DMS has its own
    systemd.user.services.niri-flake-polkit.enable = false;

    # Additional system packages to install with DMS
    environment.systemPackages = with pkgs; [
      adw-gtk3 # Support dynamic theming for gtk3 applications
      papirus-icon-theme # Icon theme
      swappy # Screenshot annotation
      seahorse # Gnome secrets manager
      nemo # File browser
      imv # image viewer

      xwayland-satellite # For X apps (like steam)
      xdg-desktop-portal-gtk
      kdePackages.dolphin # KDE file browser, better than nautilus
      kdePackages.okular # KDE pdf viewer

      # KDE/QT Package dependencies for DMS
      libsForQt5.qt5ct
      kdePackages.qt6ct
      kdePackages.kcolorscheme
      kdePackages.breeze
    ];
    services.dbus.packages = [
      pkgs.seahorse
    ];

    # DMS module includes gnome portal, but not gtk
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

    custom.hjem.cfg = {
      # Environment variables for DMS theming support
      # This may be integrated with the DMS module someday
      files.".config/environment.d/90-dms.conf".text = ''
        XDG_CURRENT_DESKTOP=niri
        QT_QPA_PLATFORM=wayland
        ELECTRON_OZONE_PLATFORM_HINT=auto
        QT_QPA_PLATFORMTHEME=qt6ct
        QT_QPA_PLATFORMTHEME_QT6=qt6ct
      '';
      # User-level customization for DMS and Niri
      rum.desktops.niri = {
        # Spawn app for logging clipboard historycd
        spawn-at-startup = [
          [
            "bash"
            "-c"
            "wl-paste --watch cliphist store &"
          ]
        ];
        # Custom DMS-specific binds
        binds = {
          "Mod+Shift+S" = {
            action = "spawn-sh \"dms screenshot --stdout | swappy -f -\"";
          };
        };
        # Additional DMS-specific configuration for niri
        config = ''
          hotkey-overlay {
              skip-at-startup
          }
          window-rule {
              match app-id=r#"^org\.gnome\."#
              draw-border-with-background false
              geometry-corner-radius 12
              clip-to-geometry true
          }
          window-rule {
              match app-id=r#"^org\.wezfurlong\.wezterm$"#
              match app-id="Alacritty"
              match app-id="zen"
              match app-id="com.mitchellh.ghostty"
              match app-id="kitty"
              draw-border-with-background false
          }
          window-rule {
            geometry-corner-radius 12
            clip-to-geometry true
          }
          // Open DMS windows as floating by default
          window-rule {
            match app-id=r#"org.quickshell$"#
            open-floating true
          }
          layer-rule {
            match namespace="^quickshell$"
            place-within-backdrop true
          }
          layout {
            struts {
              left 0
              right 0
              top 0
              bottom 0
            }
            gaps 4
            default-column-width
            center-focused-column "never"
          }
          switch-events {
            lid-close { spawn "dms" "ipc" "call" "lock" "lock"; }
          }
          // Extra niri includes files dynamically created by DMS
          include "dms/colors.kdl"
          include "dms/layout.kdl"
          include "dms/alttab.kdl"
          include "dms/binds.kdl"
          include "dms/wpblur.kdl"
        '';
      };
    };
  };
}
