{ self, ... }:
{
  flake.modules.nixos.noctalia =
    { config, inputs, pkgs, ... }:
    let
      # Pull noctalia from v5 flake
      noctaliaPackage = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    {
      # TODO: change this when I rename the quickshell module
      imports = [ self.modules.nixos.quickshell ];

      config = {
        # Import the noctalia hjem module..
        hjem.extraModules = [ inputs.noctalia.hjemModules.default ];

        # Using hjem module for noctalia (via shortcut alias)
        hj = {
          programs.noctalia = {
            enable = true;
            systemd.enable = true;
            package = noctaliaPackage;
          };
        };

        custom.programs = {
          # Will append additional niri configuration to pass to niri wrapper
          niri.settings = {
            binds = import ./_binds.nix;
            extraConfig = ''
              window-rule {
                geometry-corner-radius 20
                clip-to-geometry true
              }
              window-rule {
                match app-id="dev.noctalia.Noctalia.Settings"
                open-floating true
                default-column-width { fixed 1080; }
                default-window-height { fixed 920; }
              }
              window-rule {
                  match app-id="foot"
                  draw-border-with-background false
                  background-effect {
                      blur true
                  }
              }
              layer-rule {
                match namespace="^noctalia-backdrop"
                place-within-backdrop true
              }
              switch-events {
                lid-close { spawn "noctalia" "session" "lock"; }
              }
              debug {
                honor-xdg-activation-with-invalid-serial
              }
              // Will include dms/colors.kdl for dynamic colors if present
              include optional=true "${config.hj.directory}/.config/niri/noctalia.kdl"
            '';
          };
          # Adding additional config to foot settings
          foot.settings = {
            main.include = "~/.config/foot/themes/noctalia";
          };
        };
        
        # Some miscellaneous theming stuff to support noctalia
        hj = {
          # KDE applications configured with KColorScheme
          files.".config/kdeglobals".text = ''
            [UiSettings]
            ColorScheme=noctalia

            [Icons]
            Theme=Papirus-Dark
          '';
        };
      };
    };
}
