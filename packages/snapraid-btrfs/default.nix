{
  lib,
  pkgs,
  fetchFromGitHub,
  coreutils,
  gnugrep,
  gawk,
  gnused,
  snapraid,
  snapper,
  ...
}:
let
  name = "snapraid-btrfs";
  rev = "c749414025cb2430fd7af8bc1b626586cb55efa4";
  sha256 = "sha256-zOFc1/H2hgcZMeGUnLvuWL+SFvE5kvekm0F/dvhakWI=";

  # Using my own fork that incorporates a PR for compat with new snapper versions
  # https://github.com/automorphism88/snapraid-btrfs/pull/34
  script = builtins.readFile (
    (fetchFromGitHub {
      inherit rev sha256;
      owner = "johngalt";
      repo = "snapraid-btrfs";
    })
    + "/snapraid-btrfs"
  );
  deps = [
    coreutils
    gnugrep
    gawk
    gnused
    snapraid
    snapper
  ];
in
pkgs.writers.writeBashBin name {
  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    "${lib.makeBinPath deps}"
  ];
} script
