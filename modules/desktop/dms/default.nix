{ self, ... }:
{
  flake.modules.nixos.dms =
    { config, inputs, lib, pkgs, ... }:
    let
      inherit (lib) mkOption;
      inherit (lib.types) package;
    in
    {
      imports = [
        self.modules.nixos.quickshell # Import quickshell module as base
        inputs.dms-plugin-registry.modules.default
      ];

      # Option to set dms package to be exposed for other modules (like dms-greeter) to use
      options.custom.programs.dms = {
        package = mkOption {
          type = package;
          description = "dms-shell package to be used and exposed to other modules";
          default = inputs.dankMaterialShell.packages.${pkgs.stdenv.hostPlatform.system}.default;
        };
      };

      config = {
        # nixpkgs dms-shell module settings
        programs.dms-shell = {
          enable = true;
          package = config.custom.programs.dms.package; # Using package set in option definition above
          quickshell.package = config.custom.programs.quickshell.package; # Using package set in quickshell module
          systemd.enable = true; # Using systemd rather than niri `spawn-at-startup`

          # Core features
          enableSystemMonitoring = true; # System monitoring widgets (dgop)
          enableVPN = true; # VPN management widget
          enableDynamicTheming = true; # Wallpaper-based theming (matugen)
          enableAudioWavelength = true; # Audio visualizer (cava)
          enableCalendarEvents = false; # Calendar integration (khal)
          enableClipboardPaste = true; # Clipboard paste from history (wtype)

          # Plugins
          # These module options come from the dms-plugin-registry module (NOT nixpkgs)
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
        ];

        custom.programs = {
          # Will append additional niri configuration stuff to pass to the niri wrapper
          # TODO: nixify the rest of the config string
          niri.settings = {
            # Keeping binds in a separate file to keep things cleaner
            binds = import ./_binds.nix { inherit lib pkgs; };
            # Layout
            layout = {
              struts = { left = 0; right = 0; top = 0; bottom = 0; };
              border = { width = 2; };
              focus-ring = { width = 2; };
              gaps = 4;
              default-column-width = _: { };
              center-focused-column = "never";
            };
            # These are mainly extra window rules to match dms styling
            extraConfig = ''
              recent-windows {
                highlight {
                  corner-radius 12
                }
              }
              window-rule {
                  match app-id=r#"^org\.gnome\."#
                  draw-border-with-background false
                  geometry-corner-radius 12
                  clip-to-geometry true
              }
              window-rule {
                  match app-id="foot"
                  draw-border-with-background false
                  background-effect {
                      blur true
                  }
              }
              window-rule {
                geometry-corner-radius 12
                clip-to-geometry true
                tiled-state true
                draw-border-with-background false
              }
              window-rule {
                match app-id=r#"org.quickshell$"#
                open-floating true
              }
              layer-rule {
                match namespace="^quickshell$"
                place-within-backdrop true
              }
              layer-rule {
                match namespace="dms:blurwallpaper"
                place-within-backdrop true
              }
              switch-events {
                lid-close { spawn "dms" "ipc" "call" "lock" "lock"; }
              }
              debug {
                honor-xdg-activation-with-invalid-serial
              }
              // Will include dms/colors.kdl for dynamic colors if present
              include optional=true "${config.hj.directory}/.config/niri/dms/colors.kdl"
            '';            
          };
          # Adding additional config to foot settings
          foot.settings = {
            main.include = "~/.config/foot/dank-colors.ini";
          };
        };

        # Some miscellaneous theming stuff to support dms
        hj = {
          # Force KDE applications like Dolphin to use DankMatugen KColorScheme
          # Some KDE apps just ignore qt5/6ct stuff
          files.".config/kdeglobals".text = ''
            [UiSettings]
            ColorScheme=DankMatugen

            [Icons]
            Theme=Papirus-Dark
          '';
        };
      };
    };
}
