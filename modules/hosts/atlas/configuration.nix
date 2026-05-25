{ self, ... }:
{
  flake.modules.nixos."hosts/atlas" =
    { ... }:
    {
      imports = with self.modules.nixos; [
        # Profiles
        base
        desktop
        development
        gaming

        # System Modules
        preservation

        # Service Modules
        sanoid
        syncoid
      ];
      
      # Module settings/overrides
      custom = {
        # Placing this niri config snippet for HOST specific display setting
        # Will get merged into final config for niri wrapper
        programs.niri.settings.extraConfig = ''
          output "eDP-1" {
            mode "2880x1800@120.000"
            scale 1.5
            position x=0 y=0
            variable-refresh-rate
          }
        '';
        # Set host-specific files/directories to be persisted through reboot
        system.preservation = {
          extraDirectories = [
            "/var/lib/systemd/backlight" # backlight state
            "/var/lib/dms-greeter" # dms greeter
          ];
        };
        services = {
          # Automated ZFS snapshots
          sanoid = {
            datasets = [
              "zroot/home/taylor"
              "zroot/persist"
            ];
            ignoreSets = [
              "zroot/home/taylor/.cache"
            ];
            setRecursive = true; # creates recursive snapshots so I can ignore some child datasets
          };
          syncoid = {
            datasets = [
              "zroot/home/taylor"
              "zroot/persist"
            ];
            targetRoot = "tank/mirror/atlas";
            interval = [ ]; # empty dataset to avoid running automatically
          };
        };
      };
    };
}
