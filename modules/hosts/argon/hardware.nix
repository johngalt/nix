# TODO: Clean up file system management
{ ... }:
{
  flake.modules.nixos."hosts/argon" =
    { modulesPath, hostConfig, inputs, lib, pkgs, ... }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")

        # Declarative disk
        inputs.disko.nixosModules.default
        ./_disko.nix
        ./_diskpool.nix
      ];

      boot.initrd.availableKernelModules = [
        "vmd"
        "xhci_pci"
        "ahci"
        "nvme"
        "mpt3sas"
        "usb_storage"
        "usbhid"
        "sd_mod"
      ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ "kvm-intel" ];
      boot.extraModulePackages = [ ];
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      # Pin kernel
      boot.kernelPackages = pkgs.linuxPackages_6_18;
      
      # Enable zfs and btrfs
      boot.supportedFilesystems = [ "zfs" "btrfs" ];
      boot.zfs = {
        forceImportRoot = false;
        # Import tank pool
        extraPools = [ "tank" ];
      };
      
      environment.systemPackages = with pkgs; [
        btrfs-progs
        mergerfs
      ];

      hardware = {
        cpu.intel.updateMicrocode = true;
        enableRedistributableFirmware = true;
        intel-gpu-tools.enable = true;
      };

      networking = {
        hostName = hostConfig.name;
        hostId = "0fd4d7be"; # Needed for ZFS
        useDHCP = false; # We are using systemd networking for DHCP
        firewall = {
          allowedTCPPorts = [
            443 # ssl
            2049 # nfs
            1400 # sonos
            1883 # mqtt (home-assistant)
            8083 # qbitapi
            32400 # plex
            44262 # qbit
            2377 # docker swarm
            7946 # docker swarm
          ];
          allowedTCPPortRanges = [
            {
              # Rust Desk ports
              from = 21115;
              to = 21119;
            }
          ];
          allowedUDPPorts = [
            21116 # Rust desk
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
          matchConfig.Path = "pci-0000:0a:00.0";
          linkConfig = {
            Name = "lan";
            TransmitQueueLength = 10000;
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
