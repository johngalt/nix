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
    # Using overlays to pull unstable/recent versions of packages
    # Rather than getting version from nixpkgs, will pull/build versions from git
    nixpkgs.overlays = [
      # Overlay niri-flake for niri-unstable
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
      fwupd.enable = true; 
      accounts-daemon.enable = true;
    };

    environment.sessionVariables = {
      # Force electron apps to use wayland
      NIXOS_OZONE_WL = "1";
    };
    
    custom.hjem.cfg = {
      # The hjem rum module does not actually install niri, just configures it at the user-level
      rum.desktops.niri = {
        enable = true;
        package = null; # Disable niri config checking (will not work because of 'include's)
        # Global niri keybinds (shell-specific keybinds in own module)
        binds = import ./binds.nix;
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
          hotkey-overlay {
              skip-at-startup
          }
        '';
      };
    };
  };
}
