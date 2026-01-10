{
  ...
}:
{
  nixpkgs.overlays = [
    (final: prev: {
      snapraid-btrfs = prev.callPackage ../pkgs/snapraid-btrfs { };
      snapraid-btrfs-runner = prev.callPackage ../pkgs/snapraid-btrfs-runner { };
      qbitmover = prev.callPackage ../pkgs/qbitmover { };
      davocache = prev.callPackage ../pkgs/davocache { };
      eza-themes = prev.callPackage ../pkgs/eza-themes { };
      mergerfs-cache-mover = prev.callPackage ../pkgs/mergerfs-cache-mover { };
    })
  ];
}
