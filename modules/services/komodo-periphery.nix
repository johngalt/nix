# TODO: Will rewrite this module once the nixpkgs komodo-periphery module gets updated
# https://github.com/NixOS/nixpkgs/pull/482922
# For now will just use an oci-container. This does rely on komodo-core currently
{ ... }:
{
  flake.modules.nixos.komodo-periphery =
    { config, lib, ... }:
    let
      peripheryVersion = "2.1.2";
      peripheryRoot = "/opt/docker"; # Root directory for periphery
    in
    {
      virtualisation.oci-containers.containers."komodo-periphery" = {
        image = "ghcr.io/moghtech/komodo-periphery:${peripheryVersion}";
        environmentFiles = [ config.sops.secrets.komodo.path ]; # Env file from komodo-kore
        volumes = [
          "${peripheryRoot}:${peripheryRoot}:rw"
          "/proc:/proc:rw"
          "/var/run/docker.sock:/var/run/docker.sock:rw"
          "komodo-keys:/config/keys" # komodo-keys volume defined in komodo-core module
        ];
        labels = {
          "komodo.skip" = "";
        };
        log-driver = "journald";
        extraOptions = [
          "--network-alias=komodo-periphery"
          "--network=komodo"
        ];
      };
      systemd.services."docker-komodo-periphery" = {
        serviceConfig = {
          Restart = lib.mkOverride 90 "always";
          RestartMaxDelaySec = lib.mkOverride 90 "1m";
          RestartSec = lib.mkOverride 90 "100ms";
          RestartSteps = lib.mkOverride 90 9;
        };
        after = [
          "docker-network-komodo.service"
          "docker-volume-komodo-keys.service"
        ];
        requires = [
          "docker-network-komodo.service"
          "docker-volume-komodo-keys.service"
        ];
        partOf = [
          "docker-compose-komodo-root.target"
        ];
        wantedBy = [
          "docker-compose-komodo-root.target"
        ];
      };
    };
}
