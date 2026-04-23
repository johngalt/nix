{ ... }:
{
  flake.modules.nixos.nas =
  { ... }:
  let
    allowedIPs = "192.168.20.11";
  in
  {
    services = {
      # Expose NFS mount for media pool
      nfs.server = {
        enable = true;
        exports = ''
          /mnt/vault/media ${allowedIPs}(rw,insecure,async,no_subtree_check,all_squash,anonuid=995,anongid=131,fsid=111)
        '';
        createMountPoints = true;
      };
    };
  };
}
