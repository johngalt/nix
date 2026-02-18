{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.custom.graphical.niri;

  inherit (lib)
    mkEnableOption
    mkIf
    ;
in
{
  imports = [
    inputs.niri.nixosModules.niri
  ];

  options.custom.graphical.niri = {
    enable = mkEnableOption "Enable Niri";
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
      gvfs.enable = true; # usb device mounting
    };

    # gnupg stuff + pinentry
    programs.gnupg.agent.enable = true;

    environment.sessionVariables = {
      # Force electron apps to use wayland
      NIXOS_OZONE_WL = "1";
    };

    # Niri-flake provides a niri-portals.conf for xdg-desktop-portals
    environment.variables = {
      XDG_CURRENT_DESKTOP = "niri"; 
      QT_QPA_PLATFORM = "wayland";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
    };

    # Additional system packages to install with niri
    # Main system functionality, other apps defined in profiles
    environment.systemPackages = with pkgs; [
      # Applications
      satty # Screenshot annotation
      seahorse # Gnome secrets manager
      nautilus # Needed by Gnome portal
      xwayland-satellite # For X apps (like steam)
    ];
    # Adding some services to dbus
    services.dbus.packages = [
      pkgs.seahorse
      pkgs.nautilus
    ];

    custom.hjem.cfg = {
      # The hjem rum module does not actually install niri, just configures it at the user-level
      rum.desktops.niri = {
        enable = true;
        package = null; # Disable niri config checking (will not work because of 'include's)
        # Global niri keybinds (shell-specific keybinds in own module)
        binds = import ./binds.nix;
        # Niri global config (shell specific config will get merged with this)
        # Host specific config may be defined in host nix file
        config = ''
          prefer-no-csd
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
                  tap // Tap-to-click
                  drag true // Tap-and-drag
                  dwt // Disable when typing
                  tap-button-map "left-right-middle" // Two fingers right click
                  click-method "clickfinger"
              }
              mouse {
                scroll-factor 0.9
              }
              warp-mouse-to-focus
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
