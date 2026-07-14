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
      boot.zfs.forceImportRoot = false; # does not forcibly import root in a hard shutdown

      # Pinned kernel
      boot.kernelPackages = pkgs.linuxPackages_7_1;
      boot.zfs.package = pkgs.zfs_2_4;

      # Patch nixpkgs to allow ZFS building on 7.1
      # TODO: remove once new ZFS version is released
      # nixpkgs-patcher = {
      #   enable = true;
      #   settings.patches = with pkgs; [
      #     (fetchurl {
      #       name = "kernel_7_1_zfs.patch";
      #       url = "https://gist.githubusercontent.com/johngalt/fbf8f1290e835288e15d0751201f35c1/raw/a848dd71b1de88f12ce079c17029a7f6829fdade/kernel_7_1_zfs.patch";
      #       hash = "sha256-KecIYQMg+kxU25w/vC1oO0uKFQYqu5tawlm28H4jlDM="; # rebuild, wait for nix to fail and give you the hash, then put it here
      #     })
      #   ];
      # };

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
        hostId = "f3e20b1c"; # needed for zfs
        firewall.checkReversePath = true;
        # Prefer iwd to wpa_supplicant
        wireless.iwd = {
          enable = true;
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
