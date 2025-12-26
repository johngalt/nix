{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let 
  cfg = config.custom.graphical.niri;

  inherit (lib)
    mkIf
    ;
in 
{
  imports = [
    ./matugen
    ./themes
  ];

  config = mkIf (cfg.shell == "dms" && cfg.enable) {
    programs.dms-shell = {
      enable = true;
      package = inputs.dankMaterialShell.packages.${pkgs.stdenv.hostPlatform.system}.default; # pull latest from git

      systemd.enable = true;

      # Core features
      enableSystemMonitoring = true; # System monitoring widgets (dgop)
      enableClipboard = false; # Feature is built into DMS now, disabled until removed from nixpkgs module
      enableVPN = true; # VPN management widget
      enableDynamicTheming = true; # Wallpaper-based theming (matugen)
      enableAudioWavelength = true; # Audio visualizer (cava)
      enableCalendarEvents = true; # Calendar integration (khal)

      quickshell.package = pkgs.quickshell; # from overlay defined in niri module

    };

    # DMS specific dependencies
    environment.systemPackages = with pkgs; [
      libnotify # needed for certain dms plugins to send desktop notifications
    ];

    # Disable niri-flake polkit agent since DMS has its own
    systemd.user.services.niri-flake-polkit.enable = false;

    # User-level customization for DMS and Niri
    custom.hjem.cfg = {
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
          debug {
            // Allows notification actions and window activation
            honor-xdg-activation-with-invalid-serial
          }
          // Extra niri includes files dynamically created by DMS
          include "dms/colors.kdl"
          include "dms/layout.kdl"
          include "dms/alttab.kdl"
          include "dms/binds.kdl"
          include "dms/wpblur.kdl"
        '';
      };
      # Force KDE applications like Dolphin to use DankMatugen KColorScheme
      # Some KDE apps just ignore the ~/.config/qt{5,6}ct/ folders
      files.".config/kdeglobals".text = ''
        [UiSettings]
        ColorScheme=DankMatugen

        [Icons]
        Theme=Papirus-Dark
      '';
    };
  };
}
