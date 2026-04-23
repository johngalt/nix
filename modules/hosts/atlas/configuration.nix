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
        impermanence
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
        system.impermanence = {
          rootFilesystem = "/dev/mapper/crypted"; # LUKS encrypted drive
          persistPath = "/persist";
          extraDirectories = [
            "/etc/NetworkManager/system-connections"
            "/var/lib/systemd/backlight"
            "/var/lib/systemd/coredump"
            "/var/lib/upower"
            "/var/lib/iwd" # wireless networks
            "/var/lib/dms-greeter" # dms greeter
            "/var/lib/bluetooth" # bluetooth devices
            "/var/lib/fwupd" # firmware update daemon
          ];
          extraFiles = [
            "/var/lib/NetworkManager/secret_key"
            "/var/lib/NetworkManager/seen-bssids"
            "/var/lib/NetworkManager/timestamps"
          ];
          # TODO: Maybe finish setting this up. May not be worth it
          # Too many cache/config/state directories to keep track of
          # persistHome = {
          #   enable = true;
          # };
        };
      };
    };
}
