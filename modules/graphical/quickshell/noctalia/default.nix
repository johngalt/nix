{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let 
  cfg = config.custom.graphical.quickshell;

  noctalia = cmd: [
    "noctalia-shell" "ipc" "call"
  ] ++ (pkgs.lib.splitString " " cmd);

  inherit (lib)
    mkIf
    mkForce
    ;
in 
{
  imports = [
    inputs.noctalia.nixosModules.default
  ];

  config = mkIf (cfg.shell == "noctalia" && cfg.enable) {
    nixpkgs.overlays = [
      # Overlay noctalia package from repo into nixpkgs
      inputs.noctalia.overlays.default
    ];

    environment.systemPackages = with pkgs; [
      noctalia-shell # from overlay
    ];
    
    services.noctalia-shell = {
      enable = true;
      package = mkForce pkgs.noctalia-shell;
    };
    
    # Use polkit from niri-flake
    systemd.user.services.niri-flake-polkit.enable = true;

    custom.hjem.cfg = {
      rum.desktops.niri = mkIf config.custom.graphical.niri.enable {
        # Noctalia-specific niri binds
        binds = {
          "Mod+Space".spawn = noctalia "launcher toggle";
          "Mod+V".spawn = noctalia "launcher clipboard";
          "XF86AudioRaiseVolume" = {
            parameters = { allow-when-locked = true; };
            spawn = noctalia "volume increase";
          };
          "XF86AudioLowerVolume" = {
            parameters = { allow-when-locked = true; };
            spawn = noctalia "volume decrease";
          };
          "XF86AudioMute" = {
            parameters = { allow-when-locked = true; };
            spawn = noctalia "volume muteOutput";
          };
          "XF86AudioMicMute" = {
            parameters = { allow-when-locked = true; };
            spawn = noctalia "volume muteInput";
          };
          "XF86MonBrightnessUp".spawn = noctalia "brightness increase";
          "XF86MonBrightnessDown".spawn = noctalia "brightness decrease";
        };
        # Noctalia-specific niri configuration
        config = ''
          window-rule {
            // Rounded corners for a modern look.
            geometry-corner-radius 20

            // Clips window contents to the rounded corner boundaries.
            clip-to-geometry true
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
          // Set the overview wallpaper on the backdrop.
          layer-rule {
            match namespace="^noctalia-overview*"
            place-within-backdrop true
          }

          debug {
            // Allows notification actions and window activation from Noctalia.
            honor-xdg-activation-with-invalid-serial
          }
        '';
      };
      # Force KDE applications like Dolphin to use noctalia KColorScheme
      # Some KDE apps just ignore the ~/.config/qt{5,6}ct/ folders
      files.".config/kdeglobals".text = ''
        [UiSettings]
        ColorScheme=noctalia

        [Icons]
        Theme=Papirus-Dark
      '';
    };
  };
}
