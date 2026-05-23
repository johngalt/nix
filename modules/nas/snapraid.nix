{ ... }:
{
  flake.modules.nixos.nas =
    { lib, pkgs, ... }:
    let
      # List of data disk mounts
      dataDisks = [
        "/mnt/data-disks/data01"
        "/mnt/data-disks/data02"
        "/mnt/data-disks/data03"
      ];
      # List of content file locations for snapraid
      contentFiles = [
        "/cache/var/snapraid/snapraid.content"
        "/mnt/snapraid-content/disk01/snapraid.content"
        "/mnt/snapraid-content/disk02/snapraid.content"
        "/mnt/snapraid-content/disk03/snapraid.content"
      ];
      # Where to save snapraid parity
      parityFiles = [
        "/mnt/parity-disks/parity01/snapraid.parity"
      ];

      # Helper functions to build snapraid/snapper configs
      # Creates an attribute set: { d1 = "/mnt/data-disks/data01"; ... }
      snapraidDataDisks = builtins.listToAttrs (
        lib.lists.imap1 (i: d: {
          name = "d${toString i}";
          value = "${d}";
        }) dataDisks
      );
      # Creates an attribute set: { data01 = { ATTRIBUTES; }; ... }
      snapperConfigs = builtins.listToAttrs (
        map (d: {
          name = "${baseNameOf d}";
          value = {
            SUBVOLUME = "${d}";
            FSTYPE = "btrfs";
            TIMELINE_CREATE = false;
            SPACE_LIMIT = "0.5";
            FREE_LIMIT = "0.2";
            SYNC_ACL = "no";
            BACKGROUND_COMPARISON = "yes";
            NUMBER_CLEANUP = "yes";
            NUMBER_MIN_AGE = "3600";
            NUMBER_LIMIT = "50";
            NUMBER_LIMIT_IMPORTANT = "10";
          };
        }) dataDisks
      );

      # Healthchecks ID to ping 
      healthcheckId = "3b23ca50-133a-4d22-84ca-6a383db45eda";

      # Custom package declarations
      # snapraid-btrfs uses snapper to create snapshots prior to running snapraid
      snapraid-btrfs = pkgs.callPackage ../../packages/snapraid-btrfs { };
      # snapraid-btrfs-runner automates running snapraid-btrfs diff, sync, and scrub
      snapraid-btrfs-runner = pkgs.callPackage ../../packages/snapraid-btrfs-runner { inherit snapraid-btrfs; };
    in
    {
      environment.systemPackages = [
        snapraid-btrfs
        snapraid-btrfs-runner
      ];

      services = {
        snapraid = {
          inherit contentFiles parityFiles;
          enable = true;
          dataDisks = snapraidDataDisks;
          exclude = [
            "*.unrecoverable"
            "/tmp/"
            "/lost+found/"
            "*.!sync"
            "/.snapshots/"
          ];
          extraConfig = ''
            nohidden
            autosave 500
          '';
        };
        snapper.configs = snapperConfigs;
      };

      # Snapraid-btrfs service
      # Creates btrfs snapshots before running snapraid
      systemd.services.snapraid-btrfs-runner = {
        description = "Run the snapraid-btrfs sync with the runner";
        startAt = "06:00";
        script = ''
          ${snapraid-btrfs-runner}/bin/snapraid-btrfs-runner
        '';
        serviceConfig = {
          Type = "oneshot";
        };
        onFailure = [ "ping-healthchecks@${healthcheckId}:failure.service" ];
        onSuccess = [ "ping-healthchecks@${healthcheckId}:success.service" ];
        wants = [ "ping-healthchecks@${healthcheckId}:start.service" ];
      };

      # Disable snapraid module systemd services, since we run snapraid-btrfs runner instead (sync and scrub)
      systemd.services.snapraid-sync.enable = false;
      systemd.services.snapraid-scrub.enable = false;
    };
}
