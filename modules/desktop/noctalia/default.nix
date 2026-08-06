{ self, ... }:
{
  flake.modules.nixos.noctalia =
    { config, inputs, pkgs, ... }:
    let
      # Pull noctalia from flake
      noctaliaPackage = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    {
      # TODO: change this when I rename the quickshell module
      imports = [
        self.modules.nixos.quickshell
        inputs.noctalia.nixosModules.default
      ];

      config = {
        programs.noctalia = {
          enable = true;
          package = noctaliaPackage;
          systemd.enable = true;
          recommendedServices.enable = true;
         };

        custom.programs = {
          # Will append additional niri configuration to pass to niri wrapper
          niri.settings = {
            # Binds
            binds = import ./_binds.nix;
            # Layout
            layout = {
              struts = { left = 0; right = 0; top = 0; bottom = 0; };
              border = { width = 2; };
              focus-ring = { width = 2; };
              gaps = 4;
              default-column-width = _: { };
              center-focused-column = "never";
            };
            # Extra config
            extraConfig = ''
              recent-windows {
                highlight {
                  corner-radius 12
                }
              }
              window-rule {
                geometry-corner-radius 20
                clip-to-geometry true
              }
              window-rule {
                match app-id="dev.noctalia.Noctalia"
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
        
        # QT theming 
        programs.qtengine = {
          enable = true;
  
          config = {
            theme = {
              colorScheme = "${config.hj.directory}/.local/share/noctalia.colors";
              iconTheme = "Papirus-Dark";
              style = "breeze";

              font = {
                family = "Noto Sans";
                size = 12;
                weight = -1;
              };

              fontFixed = {
                family = "Noto Sans";
                size = 12;
                weight = -1;
              };
            };

            misc = {
              singleClickActivate = false;
              menusHaveIcons = true;
              shortcutsForContextMenus = true;
            };
          };
        };
        
        # # Some miscellaneous theming stuff to support noctalia
        # hj = {
        #   # KDE applications configured with KColorScheme
        #   files.".config/kdeglobals".text = ''
        #     [UiSettings]
        #     ColorScheme=noctalia

        #     [Icons]
        #     Theme=Papirus-Dark
        #   '';
        # };
      };
    };
}
