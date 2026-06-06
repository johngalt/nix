{ ... }:
{
  flake.modules.nixos."hosts/cesium" =
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
        "usb_storage"
        "usbhid"
        "sd_mod"
      ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ "kvm-intel" ];
      boot.extraModulePackages = [ ];
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.zfs.forceImportRoot = false; # does not forcibly import root in a hard shutdown

      # Pin kernel
      boot.kernelPackages = pkgs.linuxPackages_6_18;

      hardware.cpu.intel.updateMicrocode = true;
      hardware.enableRedistributableFirmware = true;
      hardware.rtl-sdr.enable = true; # rf receiver

      networking = {
        hostName = hostConfig.name;
        hostId = "d871150c"; # Needed for ZFS
        useDHCP = lib.mkForce false; # We are using systemd networking for DHCP
        firewall = {
          allowedTCPPorts = [
            2377 # docker swarm
            7946 # docker swaam
            1400 # sonos
          ];
          allowedUDPPorts = [
            7946 # docker swarm
            4789 # docker swarm
          ];
        };
      };

      # Use systemd networking instead
      systemd.network = {
        enable = true;
        # Rename physical adapter to `lan` rather than enp0s####
        links."10-lan" = {
          matchConfig.Path = "pci-0000:00:1f.6";
          linkConfig = {
            Name = "lan";
          };
        };
        # Match network with renamed adapter and configure DHCP
        networks."10-lan" = {
          matchConfig.Name = "lan";
          networkConfig = {
            DHCP = "ipv4";
            IPv6AcceptRA = true;
          };
          linkConfig.RequiredForOnline = "routable";
        };
      };
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    };
}
