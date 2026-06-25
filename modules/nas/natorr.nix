# Some *arr related utilities
{ ... }:
{
  flake.modules.nixos.nas =
    { pkgs, ... }:
    let
      natorr = pkgs.callPackage ../../packages/natorr { };
      noHL = pkgs.callPackage ../../packages/natorr/nohl.nix { };
    in
  {
    systemd.services.upgradinatorr = {
      description = "Natorr - upgradinatorr.py";
      startAt = [
        "*-*-* 09:00:00"
        "*-*-* 16:00:00"
      ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${natorr}/bin/upgradinatorr --config /opt/docker/arrs/natorr/upgradinatorr.yml";
      };
    };
    systemd.services.renameinatorr = {
      description = "Natorr - renameinatorr.py";
      startAt = "*-*-* 01:30:00";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${natorr}/bin/renameinatorr --config /opt/docker/arrs/natorr/renameinatorr.yml";
      };
    };
    systemd.services.noHL = {
      description = "Natorr - noHL.py";
      startAt = "*-*-* 18:00:00";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${noHL}/bin/noHL --config /opt/docker/arrs/natorr/nohl.yml";
      };
    };
  };
}
