# Host-specific hardware settings
{
  pkgs,
  ...
}:
{
  # Boot/kernel stuff
  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "nvme"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [ "xe" ];
    };
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
    # Pinned/overwritten default nix kernel version
    kernelPackages = pkgs.linuxPackages_6_19;
  };

  # Hardware/graphics
  hardware = {
    cpu.intel.updateMicrocode = true;
    bluetooth.enable = true;
    # Logitech wireles utilities for mouse/keyboard
    logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };
    graphics = {
      enable = true;
      # Intel-specific iGPU drivers
      extraPackages = with pkgs; [
        vpl-gpu-rt
        intel-media-driver
        intel-vaapi-driver
      ];
    };
  };
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD"; # Setting default driver to intel-media-driver
  };

  # Networking
  networking = {
    hostName = "atlas";
    firewall.checkReversePath = false; # Fix for wireguard
    # IWD rather than default wpa_supplicant
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
      # Force networkmanager to use the iwd backend
      wifi.backend = "iwd";
    };
  };
}
