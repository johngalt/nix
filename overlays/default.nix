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

      # Tried to override qt6ct with patched version but kept breaking things.
      # qt6Packages = prev.qt6Packages.overrideScope (
      #   qfinal: qprev: {
      #     qt6ct = qprev.qt6ct.overrideAttrs (oldAttrs: {
      #       patches = (oldAttrs.patches or [ ]) ++ [
      #         (pkgs.fetchpatch2 {
      #           url = "https://gist.githubusercontent.com/johngalt/51ae85bdc88266a45e11817aec3914e7/raw/1975f2da9d4af602a6691dc9421eeeaff05d95a5/qt6ct-shenanigans.patch";
      #           hash = "sha256-2/MRzIp1K2LqITcNvRRaR5WUQ11MmaCg+wJpR7eLu2M=";
      #         })
      #       ];
      #     });
      #   }
      # );

    })
  ];
}
