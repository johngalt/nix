{ ... }:
{
  flake.modules.nixos.technitium = {
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
        53443
      ];
    };
  };
}
