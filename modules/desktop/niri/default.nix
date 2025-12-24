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
    ./dms-greeter # display manager using greetd
    ./dms
    ./noctalia
    ./theming.nix # theming dependencies that apply to dms/noctalia
    ./xdgsettings.nix # xdg portal settings and default applications
  ];

  options.custom.desktop.niri = {
    enable = mkEnableOption "Enable Niri";
    shell = mkOption {
      type = enum [ "dms" "noctalia" ];
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
      # Overlay quickshell package with git version
      inputs.quickshell.overlays.default
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
      swappy # Screenshot annotation
      seahorse # Gnome secrets manager
      imv # image viewer
      nautilus # Gnome file browser
      kdePackages.dolphin # KDE file browser
      papers # Gnome pdf viewer

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
                  //tap // Disabled because tap is too sensitive
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
