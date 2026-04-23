{ ... }:
{
  flake.modules.nixos.dms =
    { config, pkgs, ... }:
    {
      services.displayManager.dms-greeter = {
        enable = true;
        package = config.custom.programs.dms.package; # pulling dms package from dms module
        quickshell.package = config.custom.programs.quickshell.package; # pulling quickshell from quickshell module
        compositor.name = "niri";

        configHome = config.hj.directory;
        logs = {
          save = true;
          path = "/tmp/dms-greeter.log";
        };
      };

      services.dbus.packages = [ pkgs.greetd ];
    };
}
