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
      };
    };
}
