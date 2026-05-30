{ self, ... }:
{
  flake.modules.nixos."hosts/atlas" =
    { lib, ... }:
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

      # Testing fprint
      services.fprintd.enable = true;
      
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
          extraCacheDirectories = [
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
            serviceConfig = {
              Restart = "on-failure";
              RestartSec = 1800; # Retry every 30 minutes
              StartLimitIntervalSec = 0;
            };
          };
        };
      };

      # syncoid serivce module doesn't allow me to configure the timer much
      # Manually creating systemd timer to run service daily
      # Persistent flag added to run if missed due to laptop being asleep
      systemd.timers =
        let
          datasets = [ "zroot-persist" "zroot-home-taylor" ];
          genServiceNames = map (set: "syncoid-${set}");
        in
          lib.genAttrs (genServiceNames datasets) (service: {
            wantedBy = [ "timers.target" ];
            timerConfig = {
              OnCalendar = "daily";
              Persistent = true; 
            };
          });
    };
}
