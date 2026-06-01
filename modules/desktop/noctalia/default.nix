{ self, ... }:
{
  flake.modules.nixos.noctalia =
    { inputs, pkgs, ... }:
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
              debug {
                honor-xdg-activation-with-invalid-serial
              }
            '';
          };
        };
      };
    };
}
