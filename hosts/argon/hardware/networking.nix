{
  ...
}:
{
  networking = {
    hostName = "argon";
    hostId = "0fd4d7be"; # Needed for ZFS
    useDHCP = false;
    firewall = {
      allowedTCPPorts = [
        443 # ssl
        2049 # nfs
        1883 # mqtt (home-assistant)
        8083 # qbitapi
        32400 # plex
        34400 # threadfin
        44262 # qbit
      ];
    };
  };

  # Use systemd networking by default
  systemd.network.enable = true;

  # Use standard lan network to keep consistency
  systemd.network.links."10-lan" = {
    matchConfig.Path = "pci-0000:06:00.0";
    linkConfig.Name = "lan";
  };
  systemd.network.networks."10-lan" = {
    matchConfig.Name = "lan";
    networkConfig = {
      DHCP = "ipv4";
      IPv6AcceptRA = true;
    };
    linkConfig.RequiredForOnline = "routable";
  };
}
