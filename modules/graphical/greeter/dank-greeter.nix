{
  config,
  lib,
  pkgs,
  inputs,
  private,
  ...
}:
let
  cfg = config.custom.graphical.greeter;

  # Set greeterUser for syncing theme from DMS
  greeterUser = private.username;
  # Using packages built from git provided by the respective flakes
  # TODO: Change this to reference package exposed by dms module and quickshell module
  dankPackage = inputs.dankMaterialShell.packages.${pkgs.stdenv.hostPlatform.system}.default;
  quickshellPackage = config.custom.graphical.quickshell.package; # Pulling package from quickshell module

  inherit (lib)
    mkEnableOption
    mkIf
    ;
in
{
  options.custom.graphical.greeter = {
    enable = mkEnableOption "Enable dank greeter (DMS)";
  };

  config = mkIf cfg.enable {
    services.displayManager.dms-greeter = {
      enable = true;
      package = dankPackage;
      quickshell.package = quickshellPackage;
      compositor.name = "niri";

      # Sync greeter theme with DMS
      configHome = "/home/${greeterUser}";

      # Save the logs to a file
      logs = {
        save = true;
        path = "/tmp/dms-greeter.log";
      };
    };

    services.dbus.packages = [
      pkgs.greetd
    ];
  };
}
