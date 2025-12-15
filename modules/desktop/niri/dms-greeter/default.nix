{
  config,
  lib,
  inputs,
  pkgs,
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
  imports = [
    inputs.dankMaterialShell.nixosModules.greeter
  ];

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
    programs.dankMaterialShell.greeter = {
      enable = true;
      compositor = {
        name = cfg.compositor;
      };

      # Sync greeter theme with DMS
      configHome = "/home/${cfg.user}";

      # Save the logs to a file
      logs = {
        save = true;
        path = "/tmp/dms-greeter.log";
      };

      # Use same quickshell package as dms flake
      quickshell.package = config.programs.dankMaterialShell.quickshell.package;
    };

    # Idk if this is needed or not
    services.dbus.packages = [
      pkgs.greetd
    ];
  };
}
