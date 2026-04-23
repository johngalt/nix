{ ... }:
{
  flake.modules.nixos."hosts/incus" =
    { modulesPath, hostConfig, inputs, lib, pkgs, ... }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")

        # Declarative disk
        inputs.disko.nixosModules.default
        ./_disko.nix
      ];

      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ "kvm-intel" ];
      boot.extraModulePackages = [ ];
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      boot.supportedFilesystems = [ "zfs" ];

      # Pin kernel
      boot.kernelPackages = pkgs.linuxPackages_6_18;
      
      hardware.cpu.intel.updateMicrocode = true;
      hardware.enableRedistributableFirmware = true;

      networking = {
        hostName = hostConfig.name;
        hostId = "777a7a13"; # Needed for ZFS
        useDHCP = lib.mkForce false; # We are using systemd networking for DHCP
        firewall = {
          allowedTCPPorts = [
            443 # ssl
            8443 # incus webui
            53 # technitium dns server
            67 # dhcp
          ];
          allowedUDPPorts = [
            53 # dns
            67 # dhcp
          ];
        };
        nftables.enable = true; # Preferred for incus over iptables
      };

      # Use systemd networking instead
      systemd.network = {
        enable = true;
        # Create virtual bridge adapter for VMs to use
        netdevs = {
          "10-br0" = {
            netdevConfig = {
              Kind = "bridge";
              Name = "br0";
            };
          };
        };
        networks = {
          # Connect physical network to bridge
          "20-enp0s31f6" = {
            matchConfig.Name = "enp0s31f6";
            networkConfig.Bridge = "br0";
            linkConfig.RequiredForOnline = "enslaved";
          };
          # Configure bridge network with DHCP
          "40-br0" = {
            matchConfig.Name = "br0";
            bridgeConfig = { };
            networkConfig = {
              DHCP = "ipv4";
              IPv6AcceptRA = true;
            };
            linkConfig = {
              RequiredForOnline = "carrier";
            };
          };
        };
      };
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    };
}
