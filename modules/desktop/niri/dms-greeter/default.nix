{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.custom.desktop.dms-greeter;
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
  options.custom.desktop.dms-greeter = {
    enable = mkEnableOption "Enable dms-greeter";
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
      # Use same dms-shell package (dms-greeter is part of this)
      package = inputs.dankMaterialShell.packages.${pkgs.stdenv.hostPlatform.system}.default; 

      compositor.name = cfg.compositor;

      # Sync greeter theme with DMS
      configHome = "/home/${cfg.user}";

      # Save the logs to a file
      logs = {
        save = true;
        path = "/tmp/dms-greeter.log";
      };

      # Quickshell from overlays
      quickshell.package = pkgs.quickshell;
    };
    
    # Idk if this is needed or not
    services.dbus.packages = [
      pkgs.greetd
    ];
  };
}
