{ inputs, ... }:
{
  # Quickshell base module, to be imported by a shell module
  # TODO: Rename this to be common environment or something, since its not quickshell specific
  flake.modules.nixos.quickshell =
    { lib, pkgs, ... }:
    let
      inherit (lib) mkOption;
      inherit (lib.types) package;
    in
    {
      # Allow for declarative QT theming
      imports = [ inputs.qtengine.nixosModules.default ];

      # Create a module option that holds the quickshell package to be passed to other modules
      options ={
        custom.programs.quickshell = {
          package = mkOption {
            type = package;
            description = "Quickshell package to expose to other modules";
            # default = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default;
            default = pkgs.quickshell;
          };
        };
      };

      config = {
        # Will install some global system packages that support shells
        environment.systemPackages = with pkgs; [
          # Qt5/6ct for most QT theming
          libsForQt5.qt5ct
          kdePackages.qt6ct
          # KColorScheme used for KDE apps
          kdePackages.kcolorscheme
          # KDE Breeze theme used as base for most QT stuff
          kdePackages.breeze
          kdePackages.breeze.qt5
          # Adw theme for GTK stuff
          adw-gtk3
          # Papirus icon theme with override for folder color
          # (papirus-icon-theme.overrideAttrs (old: {
          #   color = "green";
          #   dontFixup = true; # this makes building take forever
          # }))
          papirus-icon-theme
        ];

        # QT THEMING
        # Set environmental variables to force Qt apps to use qt6ct
        environment.variables = {
          # Set QT apps to follow qt6ct theme settings by default
          # QT_QPA_PLATFORMTHEME = "qt6ct";
          # QT_QPA_PLATFORMTHEME_QT6 = "qt6ct";
          # Going to use qtengine instead
          QT_QPA_PLATFORMTHEME = "qtengine";
          QT_QPA_PLATFORMTHEME_QT6 = "qtengine";
        };

        # GTK THEMING
        # Use dconf to force gnome/gtk apps to use custom theme settings
        programs.dconf.profiles.user.databases = [
          {
            settings = {
              # Default icon pack
              "org/gnome/desktop/interface" = {
                icon-theme = "Papirus-Dark"; # Icon pack
                gtk-theme = "adw-gtk3"; # Set adw as gtk3 theme
              };
            };
          }
        ];
      };
    };
}
