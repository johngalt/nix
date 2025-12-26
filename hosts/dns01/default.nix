{
  config,
  private,
  ...
}:
{
  imports = [
    ./hardware
  ];

  # SOPS definitions for host
  sops.secrets."beszel/sshkey" = { };
  sops.secrets."beszel/dns01token" = { };
  sops.templates."beszel-agent".content = ''
    HUB_URL=https://beszel.${private.domain}
    KEY=${config.sops.placeholder."beszel/sshkey"}
    TOKEN=${config.sops.placeholder."beszel/dns01token"}
  '';

  # Custom module settings
  custom = {
    profiles.base.enable = true;
    services = {
      beszel = {
        enable = true;
        environmentFile = config.sops.templates."beszel-agent".path;
      };
    };

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
  networking.hostName = "dns01";
  networking.domain = private.domain;
  networking.firewall.enable = true;
  networking.useDHCP = true;
}
