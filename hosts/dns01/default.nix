{
  private,
  ...
}:
{
  # Custom module settings
  custom = {
    profiles.base.enable = true;
    profiles.server.enable = true;
  };

  # Technitium DNS server
  services.technitium-dns-server = {
    enable = true;
    openFirewall = true;
    firewallUDPPorts = [
      53
      853
      443
    ];
    firewallTCPPorts = [
      5380
      53
      853
      443
    ];
  };

  # Networking settings. Not enough to break into own file
  networking = {
    hostName = "dns01";
    domain = private.domain;
    firewall.enable = true;
    useDHCP = true;
  };
}
