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
    ./themes
  ];

  config = mkIf (cfg.shell == "dms" && cfg.enable) {
    # Using overlays to pull unstable/recent versions of packages
    # Rather than getting version from nixpkgs, will pull/build versions from git
    nixpkgs.overlays = [
      # Overlay quickshell package with git version
      inputs.quickshell.overlays.default
      # Overlay dms-shell package with git version
      (final: prev: { dms-shell = inputs.dankMaterialShell.packages.${pkgs.stdenv.hostPlatform.system}.default; })
    ];

    programs.dms-shell = {
      enable = true;
      package = pkgs.dms-shell; # from overlay above

      systemd.enable = true;

      # Core features
      enableSystemMonitoring = true; # System monitoring widgets (dgop)
      enableClipboard = false; # Feature is built into DMS now, disabled until removed from nixpkgs module
      enableVPN = true; # VPN management widget
      enableDynamicTheming = true; # Wallpaper-based theming (matugen)
      enableAudioWavelength = true; # Audio visualizer (cava)
      enableCalendarEvents = true; # Calendar integration (khal)

      quickshell.package = pkgs.quickshell; # from overlay above

    };

    # Add additional parameter to systemd service to only start with niri
    # systemd.user.services.dms = {
    #   wants = [ "niri.service" ];
    # };

    # Disable niri-flake polkit agent since DMS has its own
    systemd.user.services.niri-flake-polkit.enable = false;

    # Additional system packages to install with DMS
    environment.systemPackages = with pkgs; [
      adw-gtk3 # Support dynamic theming for gtk3 applications
      papirus-icon-theme # Icon theme
      swappy # Screenshot annotation
      seahorse # Gnome secrets manager
      nemo # Alternative file browser
      imv # image viewer
      nautilus # Gnome file browser

      xwayland-satellite # For X apps (like steam)
      xdg-desktop-portal-gtk
      kdePackages.dolphin # KDE file browser
      kdePackages.okular # KDE pdf viewer

      # KDE/QT Package dependencies for DMS
      libsForQt5.qt5ct
      kdePackages.qt6ct
      kdePackages.kcolorscheme
      kdePackages.breeze
    ];
    services.dbus.packages = [
      pkgs.seahorse
      pkgs.nautilus
    ];

    # DMS module includes gnome portal, but not gtk
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    xdg.portal.xdgOpenUsePortal = true;

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
        # Custom DMS-specific binds
        binds = {
          "Mod+Shift+S" = {
            action = "spawn-sh \"dms screenshot --stdout | swappy -f -\"";
          };
        };
        # Additional DMS-specific configuration for niri
        config = ''
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
          window-rule {
            match app-id="firefox" title="Bitwarden"
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
