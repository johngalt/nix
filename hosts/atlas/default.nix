{
  ...
}:
{
  imports = [
    ./hardware # Host hardware configuration
  ];

  # Custom module settings
  custom = {
    # Base and desktop profiles enabled
    profiles = {
      base.enable = true;
      desktop.enable = true;
      development.enable = true;
    };

    programs.steam.enable = false;

    # Placing this niri config snippet for HOST specific display setting
    hjem.cfg.rum.desktops.niri.config = ''
      output "eDP-1" {
        mode "2880x1800@120.000"
        scale 1.5
        position x=0 y=0
        variable-refresh-rate
      }
    '';
    
    # Impermanence
    system.impermanence = {
      enable = true;
      rootFilesystem = "/dev/mapper/crypted"; # LUKS encrypted drive
      persistPath = "/persist";
      directories = [
        "/etc/NetworkManager/system-connections"
        "/var/lib/systemd/backlight"
        "/var/lib/systemd/coredump"
        "/var/lib/upower"
        "/var/lib/iwd" # wireless networks
        "/var/lib/dms-greeter" # dms greeter
        "/var/lib/bluetooth" # bluetooth devices
        "/var/lib/fwupd" # firmware update daemon
      ];
      files = [
        "/var/lib/NetworkManager/secret_key"
        "/var/lib/NetworkManager/seen-bssids"
        "/var/lib/NetworkManager/timestamps"
      ];
    };
  };
}
