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

      nixd = prev.nixd.overrideAttrs (old: {
        src = prev.fetchFromGitHub {
          owner = "nix-community";
          repo = "nixd";
          tag = "2.7.0";
          hash = "sha256-VPUX/68ysFUr1S8JW9I1rU5UcRoyZiCjL+9u2owrs6w=";
        };
      });
      nixf = prev.nixf.overrideAttrs (old: {
        src = prev.fetchFromGitHub {
          owner = "nix-community";
          repo = "nixd";
          tag = "2.7.0";
          hash = "sha256-VPUX/68ysFUr1S8JW9I1rU5UcRoyZiCjL+9u2owrs6w=";
        };
      });
    })
  ];
}
