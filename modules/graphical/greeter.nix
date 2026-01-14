{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.custom.graphical.greeter;

  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    ;
  inherit (lib.types)
    str
    ;
in
{
  options.custom.graphical.greeter = {
    enable = mkEnableOption "Enable dank greeter (DMS)";
    user = mkOption {
      type = str;
      description = "Default greeter user";
      default = "";
    };
    compositor = mkOption {
      type = str;
      description = "Which compositor to use (niri, hyprland, sway)";
      default = "niri";
    };
  };

  # Don't enable this greeter if sddm is already enabled via plasma module
  config = mkIf (cfg.enable && !config.services.displayManager.sddm.enable) {
    
    services.displayManager.dms-greeter = {
      enable = true;
      # Override nixpkgs dms-shell with package from dms git
      package = inputs.dankMaterialShell.packages.${pkgs.stdenv.hostPlatform.system}.default;

      compositor.name = cfg.compositor;

      # Sync greeter theme with DMS
      configHome = "/home/${cfg.user}";

      # Save the logs to a file
      logs = {
        save = true;
        path = "/tmp/dms-greeter.log";
      };

      quickshell.package = pkgs.quickshell; # This is an overlay from quickshell module
    };
    
    # Idk if this is needed or not
    services.dbus.packages = [
      pkgs.greetd
    ];
  };
}
