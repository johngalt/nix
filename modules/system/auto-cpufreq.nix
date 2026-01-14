{
  config,
  inputs,
  lib,
  ...
}:
let
  cfg = config.custom.system.auto-cpufreq;
  inherit (lib)
    mkEnableOption
    mkIf
    ;
in
{
  imports = [
    inputs.auto-cpufreq.nixosModules.default
  ];

  options.custom.system.auto-cpufreq = {
    enable = mkEnableOption "Enable auto-cpufreq module";
  };

  config = mkIf cfg.enable {
    services.auto-cpufreq = {
      enable = true;
      settings = {
        charger = {
          governor = "performance";
          energy_performance_preference = "performance";
          turbo = "auto";
        };
        power_supply_ignore_list = {
          logitechmouse = "hidpp_battery_0";
        };
        battery = {
          governor = "powersave";
          energy_performance_preference = "power";
          turbo = "auto";
        };
      };
    };
  };
}
