{ ... }:
{
  flake.modules.nixos.scrutiny =
    { config, lib, pkgs, hostConfig, private, ... }:
    let
      # Will use forked version of scrutiny as the package for the module
      collectorPackage = pkgs.callPackage ../../packages/scrutiny-collector { };
      scheduleTime = "04:00";
      apiEndpoint = "https://scrutiny.${private.domain}";
      hostId = hostConfig.name;

      inherit (lib) mkIf;
    in
    {
      services.scrutiny.collector = {
        enable = true;
        package = collectorPackage;
        schedule = scheduleTime;
        settings.api.endpoint = apiEndpoint;
        settings.host.id = hostId;
      };

      # Override the nixpkgs module to add zfs collector to systemd script
      # Will only be added if the host has a zfs filesystem
      systemd.services.scrutiny-collector = mkIf (builtins.hasAttr "zfs" config.boot.supportedFilesystems) {
        serviceConfig = {
          ExecStart = lib.mkForce [
            "${collectorPackage}/bin/scrutiny-collector-metrics run --config /run/scrutiny-collector/config.yaml"
            "${collectorPackage}/bin/scrutiny-collector-zfs run"
          ];
        };
      };
    };
}
