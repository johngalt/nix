{
  networking = {
    hostName = "atlas";
    firewall.checkReversePath = false; # Fix for wireguard
    # IWD rather than wpa_supplicant
    wireless.iwd = {
      enable = true;
      settings = {
        Rank = {
          # Prefer 5GHz network
          BandModifier5GHz = 3.0;
        };
        Settings = {
          # Change roam threshold to prevent roaming too much on a weak connection
          RoamThreshold5G = -80;
          CriticalRoamThreshold5G = -85;
        };
      };
    };
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };
  };

  # Wait for wlan device to come online before starting IWD
  systemd = {
    services = {
      "iwd" = {
        after = [ "sys-devices-pci0000:00-0000:00:02.3-0000:c3:00.0-net-wlan0.device" ];
        wants = [ "sys-devices-pci0000:00-0000:00:02.3-0000:c3:00.0-net-wlan0.device" ];
      };
    };
  };
}
