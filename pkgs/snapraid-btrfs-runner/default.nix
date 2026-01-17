{
  lib,
  pkgs,
  fetchFromGitHub,
  writeTextFile,
  snapper,
  snapraid,
  snapraid-btrfs,
  ...
}:
let
  name = "snapraid-btrfs-runner";
  rev = "afb83c67c61fdf3769aab95dba6385184066e119";
  hash = "sha256-M8LXxsc7jEn5GsiXAKykmFUgsij2aOIenw1Dx+/5Rww=";

  script = builtins.readFile (
    (fetchFromGitHub {
      owner = "fmoledina";
      repo = name;
      inherit rev hash;
    })
    + "/snapraid-btrfs-runner.py"
  );

  config = writeTextFile {
    name = "snapraid-btrfs-runner.conf";
    text = ''
      [snapraid-btrfs]
      ; path to the snapraid-btrfs executable (e.g. /usr/bin/snapraid-btrfs)
      executable = ${snapraid-btrfs}/bin/snapraid-btrfs
      ; optional: specify snapper-configs and/or snapper-configs-file as specified in snapraid-btrfs
      ; only one instance of each can be specified in this config
      snapper-configs =
      snapper-configs-file =
      ; specify whether snapraid-btrfs should run the pool command after the sync, and optionally specify pool-dir
      pool = false
      pool-dir =
      ; specify whether snapraid-btrfs-runner should automatically clean up all but the last snapraid-btrfs sync snapshot after a successful sync
      cleanup = true

      [snapper]
      ; path to snapper executable (e.g. /usr/bin/snapper)
      executable = ${snapper}/bin/snapper

      [snapraid]
      ; path to the snapraid executable (e.g. /usr/bin/snapraid)
      executable = ${snapraid}/bin/snapraid
      ; path to the snapraid config to be used
      config = /etc/snapraid.conf
      ; abort operation if there are more deletes than this, set to -1 to disable
      deletethreshold = 100
      ; if you want touch to be ran each time
      touch = false

      [logging]
      ; logfile to write to, leave empty to disable
      file =
      ; maximum logfile size in KiB, leave empty for infinite
      maxsize = 5000

      [email]
      ; when to send an email, comma-separated list of [success, error]
      sendon = error
      ; set to false to get full programm output via email
      short = true
      subject = [SnapRAID] Status Report:
      from = 
      to = 
      ; maximum email size in KiB
      maxsize = 500

      [smtp]
      host = localhost
      ; leave empty for default port
      port = 8025
      ; set to "true" to activate
      ssl = false
      tls = false
      user =
      password =

      [scrub]
      ; set to true to run scrub after sync
      enabled = true
      ; plan can be 0-100 percent, new, bad, or full
      plan = 8
      ; only used for percent scrub plan
      older-than = 10
    '';
    destination = "/etc/${name}";
  };

  deps = [
    snapraid
    snapraid-btrfs
    snapper
  ];
in
pkgs.writers.writePython3Bin name {
  doCheck = false;
  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    "${lib.makeBinPath deps}"
    "--add-flag"
    "-c"
    "--add-flag"
    "${config}/etc/snapraid-btrfs-runner"
  ];
} script
