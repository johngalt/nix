{
  lib,
  private,
  ...
}:
{
  networking = {
    hostName = "incus";
    domain = private.domain;
    hostId = "777a7a13"; # Needed for ZFS
    firewall = {
      allowedTCPPorts = [
        443 # ssl
        8443 # incus webui
        53
        67
      ];
      allowedUDPPorts = [
        53
        67
      ];
    };
    useDHCP = lib.mkForce false; # disable dhcpd since we are using networkd
    nftables.enable = true; # Preferred for incus
  };

  systemd.network = {
    enable = true;
    # Creating bridge network for VMs to use
    netdevs = {
      "10-br0" = {
        netdevConfig = {
          Kind = "bridge";
          Name = "br0";
          # MACAddress = "30:5a:3a:e1:4d:37";
        };
      };
    };
    networks = {
      "20-enp0s31f6" = {
        matchConfig.Name = "enp0s31f6";
        networkConfig.Bridge = "br0";
        linkConfig.RequiredForOnline = "enslaved";
      };
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
}
