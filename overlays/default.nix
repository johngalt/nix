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
      qt6ct-kde = prev.qt6Packages.callPackage ../pkgs/qt6ct-kde { };

      # qt6Packages = prev.qt6Packages.overrideScope (qfinal: qprev: {
      #   qt6ct = prev.qt6Packages.callPackage ../pkgs/qt6ct-kde { };
      # });
    })
  ];
}
