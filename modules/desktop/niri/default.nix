{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.custom.desktop.niri;

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
    inputs.niri.nixosModules.niri
    ./dms
    ./dms-greeter
  ];

  options.custom.desktop.niri = {
    enable = mkEnableOption "Enable Niri";
    shell = mkOption {
      type = enum [ "dms" ];
      description = "Which shell to use for niri";
      default = "dms";
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      # Overlay from niri-flake
      inputs.niri.overlays.niri
    ];
    
    programs.niri = {
      enable = true;
      # Pull latest niri from niri-flake
      package = pkgs.niri-unstable;
    };

    # Various services to run when using niri (KDE module includes these when using Plasma)
    # Some of these may be included in the niri or dms nix module and become redundant
    services = {
      power-profiles-daemon.enable = true;
      upower.enable = true;
      libinput.enable = true;
      fwupd.enable = true; # Firmware update daemon
      accounts-daemon.enable = true;
    };

    environment.sessionVariables = {
      # Force electron apps to use wayland
      NIXOS_OZONE_WL = "1";
    };
    
    custom.hjem.cfg = {
      rum.desktops.niri = {
        enable = true;
        package = null; # Disable niri config checking
        # Global niri keybinds (shell-specific keybinds in own module)
        binds = {
          "Mod+T" = {
            spawn = [ "alacritty" ];
          };
          "Mod+Q" = {
            parameters = {
              repeat = false;
            };
            action = "close-window";
          };
          "Mod+Left" = {
            action = "focus-column-left";
          };
          "Mod+Shift+Left" = {
            action = "move-column-left";
          };
          "Mod+Ctrl+Left" = {
            action = "consume-or-expel-window-left";
          };
          "Mod+Up" = {
            action = "focus-workspace-up";
          };
          "Mod+Shift+Up" = {
            action = "move-window-up-or-to-workspace-up";
          };
          "Mod+Right" = {
            action = "focus-column-right";
          };
          "Mod+Shift+Right" = {
            action = "move-column-right";
          };
          "Mod+Ctrl+Right" = {
            action = "consume-or-expel-window-right";
          };
          "Mod+Down" = {
            action = "focus-workspace-down";
          };
          "Mod+Shift+Down" = {
            action = "move-window-down-or-to-workspace-down";
          };
          "Mod+Return" = {
            action = "maximize-column";
          };
          "Mod+Shift+Return" = {
            action = "set-column-width \"50%\"";
          };
          "Mod+Shift+Space" = {
            action = "toggle-windowed-fullscreen";
          };
        };
        # Niri global config (shell specific config will get merged with this)
        config = ''
          input {
              keyboard {
                  xkb { 
                      layout "us"
                  }
                  repeat-delay 600
                  repeat-rate 25
                  track-layout "global"
              }
              touchpad { 
                  tap // Tap to click
                  dwt // Disable when typing
                  tap-button-map "left-right-middle" // Two fingers right click
                  click-method "clickfinger"
              }
          }
          cursor {
              xcursor-theme "breeze_cursors"
              xcursor-size 24
          }
        '';
      };
    };
  };
}
