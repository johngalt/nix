{ inputs, self, ... }:
{
  # This defines the niri wrapper via flake-parts
  # The nix-wrapper-modules module is imported via `wlib.wrapperModules`
  # I've set the base package to be "wrapped" to be niri-unstable from the niri-flake
  flake.wrappers.niri =
    { wlib, pkgs, ... }:
    {
      imports = [ wlib.wrapperModules.niri ];
      package = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable;
    };

  flake.modules.nixos.niri =
    { config, lib, pkgs, ... }:
    let
      # Passing my config via settings option to the wrapper
      niriWrapped = self.wrappers.niri.apply {
        inherit pkgs;
        inherit (config.custom.programs.niri) settings;
      };
    in
    {
      # Creating custom option for niri config that will be passed to wrapper
      # Will allow me to extend upon config in other modules (like dms)
      options.custom.programs.niri = {
        settings = lib.mkOption {
          type = lib.types.submodule {
            # Need to use attrsOf anything type to recursively merge attributes set across modules
            freeformType = lib.types.attrsOf lib.types.anything;
            # Default `extraConfig` option from wrapper is just a string, which cant merge
            options.extraConfig = lib.mkOption {
              type = lib.types.lines;
              default = "";
              description = "Additional configuration lines";
            };
          };
        };
      };

      config = {
        # Lets get the actual package from the niri wrapper via `.wrapper`
        programs.niri = {
          enable = true;
          package = niriWrapped.wrapper; # Wrapped niri package
        };

        # Will use my custom module option to create the niri config to pass to the wrapper
        # TODO: nixify the rest of the config string
        custom.programs.niri.settings = {
          # Binds are in a separate file to keep things clean
          binds = import ./_binds.nix { inherit pkgs lib config; };
          spawn-at-startup = [
            [ "${lib.getExe pkgs.solaar}" "--window=hide" ] # Logitech wireless utility
          ];
          # Some things are just easier to pass as a line of strings ...
          extraConfig = ''
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

        # Various services to run when using niri
        # Some of these may be included in the niri or various shell modules and be redundant
        services = {
          power-profiles-daemon.enable = true;
          upower.enable = true;
          libinput.enable = true;
          fwupd.enable = true;
          accounts-daemon.enable = true;
          gvfs.enable = true; # usb device mounting
        };

        # Pinentry stuff
        programs.gnupg.agent.enable = true;

        # Environment variables to force wayland/niri
        environment.variables = {
          XDG_CURRENT_DESKTOP = "niri";
          QT_QPA_PLATFORM = "wayland";
          ELECTRON_OZONE_PLATFORM_HINT = "auto";
          NIXOS_OZONE_WL = "1"; # force electron apps to use wayland
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
        # Adding some services to dbus that require it
        services.dbus.packages = with pkgs; [
          seahorse
          nautilus
        ];

        # This is just a little something to reload the niri config on system rebuild
        # Nix path will change so I pull it from the wrapper via `.constructFiles.generatedConfig`
        # Taken from https://github.com/iynaix/dotfiles
        system.userActivationScripts = {
          niri-reload-config = {
            text = lib.getExe (
              pkgs.writeShellApplication {
                name = "niri-reload-config";
                runtimeInputs = [
                  config.programs.niri.package
                  pkgs.procps
                ];
                text = ''
                  if pgrep -x "niri" > /dev/null; then
                    niri msg action load-config-file --path "${niriWrapped.constructFiles.generatedConfig.outPath}"
                  fi
                '';
              }
            );
          };
        };
      };
    };
}
