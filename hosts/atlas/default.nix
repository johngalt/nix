{
  lib,
  ...
}:
{
  imports = [
    ./hardware # Host hardware configuration
  ];

  # Custom module settings
  custom = {
    # Common and personal profiles enabled
    profiles = {
      common.enable = true;
      personal.enable = true;
    };

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
        "/var/lib/dms-greeter"
      ];
      files = [
        "/var/lib/NetworkManager/secret_key"
        "/var/lib/NetworkManager/seen-bssids"
        "/var/lib/NetworkManager/timestamps"
        "/var/lib/sddm/state.conf"
      ];
    };
    programs = {
      syncthing.enable = true;
    };
    desktop = {
      niri = {
        enable = true;
      };
    };
  };
}
