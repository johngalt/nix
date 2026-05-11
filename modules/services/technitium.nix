{ ... }:
{
  flake.modules.nixos.technitium =
    { lib, pkgs, ... }:
    let
      # TODO: remove when 15.2 gets to nixpkgs
      technitium-dns-server-library = pkgs.callPackage ../../packages/technitium-dns-server-library/package.nix {};
      technitium-dns-server = pkgs.callPackage ../../packages/technitium-dns-server/package.nix { inherit technitium-dns-server-library; };
    in
    {

    # Networkd enables resoled, need to force it disabled
    # Resolved tries to bind port 53 which interferes with technitium
    services.resolved.enable = lib.mkForce false;
    # Force resolvconf to use local DNS (technitium)
    networking.resolvconf.useLocalResolver = lib.mkForce true;

    services.technitium-dns-server = {
      enable = true;
      package = technitium-dns-server;
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
