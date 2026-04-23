{ ... }:
{
  flake.modules.nixos."hosts/atlas" =
    { modulesPath, hostConfig, inputs, lib, pkgs, ... }:
    {
      imports = [
        (modulesPath + "/hardware/cpu/intel-npu.nix")
        (modulesPath + "/installer/scan/not-detected.nix")

        # Declarative disk
        inputs.disko.nixosModules.default
        ./_disko.nix
      ];
      
      boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usbhid" "usb_storage" "sd_mod" ];
      boot.initrd.kernelModules = [ "xe" ];
      boot.kernelModules = [ "kvm-intel" ];
      boot.extraModulePackages = [ ];
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      # Pinned kernel
      boot.kernelPackages = pkgs.linuxPackages_7_0;

      hardware = {
        enableRedistributableFirmware = true;
        cpu = {
          intel.npu.enable = true;
          intel.updateMicrocode = true;
        };
        graphics = {
          enable = true;
          # Drivers for intel iGPU
          extraPackages = with pkgs; [
            vpl-gpu-rt
            intel-media-driver
            intel-vaapi-driver
          ];
        };
        bluetooth.enable = true;
        # Drivers/software for Logitech peripherals
        logitech.wireless = {
          enable = true;
          enableGraphical = true;
        };
      };

      # Force VA-API to use intel-media-driver
      environment.sessionVariables = {
        LIBVA_DRIVER_NAME = "iHD";
      };

      networking = {
        hostName = hostConfig.name; 
        firewall.checkReversePath = true;
        # Prefer iwd to wpa_supplicant
        wireless.iwd = {
          enable = true;
          settings = {
            # Bump 5GHz priority when roaming
            Rank = {
              BandModifier5GHz = 3.0; # Prefer 5GHz
            };
            Settings = {
              RoamThreshold5G = -80;
              CriticalRoamThreshold5G = -85;
            };
          };
        };
        # Force networkmanager to use iwd as backend
        networkmanager = {
          enable = true;
          wifi.backend = "iwd";
        };
      };
      
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    };
}
