{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.graphical.quickshell;

  # Will use dms-shell package from flake rather than nixpkgs
  dmsPackage = inputs.dankMaterialShell.packages.${pkgs.stdenv.hostPlatform.system}.default;
  # Will use quickshell package defined in the quickshell module option
  qsPackage = cfg.package;

  inherit (lib)
    mkIf
    ;
in
{
  imports = [
    inputs.dms-plugin-registry.modules.default
  ];

  config = mkIf (cfg.shell == "dms" && cfg.enable) {
    programs.dms-shell = {
      enable = true;
      package = dmsPackage; # Defined in let binding, pulled from dms flake
      quickshell.package = qsPackage; # Defined in let binding, pulled from quickshell module
      systemd.enable = true;

      # Core features
      enableSystemMonitoring = true; # System monitoring widgets (dgop)
      enableVPN = true; # VPN management widget
      enableDynamicTheming = true; # Wallpaper-based theming (matugen)
      enableAudioWavelength = true; # Audio visualizer (cava)
      enableCalendarEvents = false; # Calendar integration (khal)
      enableClipboardPaste = true; # Clipboard paste from history (wtype)

      # Plugins
      plugins = {
        # gruvboxMaterial.enable = true; # Themes not supported by module yet
        calculator.enable = true;
        dankGifSearch.enable = true;
        dankBatteryAlerts.enable = true;
        dankNotepadModule.enable = true;
        homeAssistantMonitor.enable = true;
      };
    };

    # DMS specific dependencies
    environment.systemPackages = with pkgs; [
      libnotify # needed for certain dms plugins to send desktop notifications
      satty # screenshot annotation
    ];

    # Disable niri-flake polkit agent since DMS has its own
    systemd.user.services.niri-flake-polkit.enable = false;

    # User-level customization for DMS and Niri
    custom = {
      hjem.cfg = {
        rum.desktops.niri = mkIf config.custom.graphical.niri.enable {
          # Custom DMS-specific binds
          binds = import ./_binds.nix;

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
                match app-id="foot"
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
              // Lock laptop when lid is closed
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
            include "dms/windowrules.kdl"
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
      # Some various program tweaks/themes for DMS
      programs = {
        foot.settings = {
          main.include = "~/.config/foot/dank-colors.ini";
        };
      };
    };
  };
}
