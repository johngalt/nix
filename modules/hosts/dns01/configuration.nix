# VM Configuration. To build/deploy on incus:
# > nix build .#nixosConfigurations.test.config.system.build.qemuImage --print-out-paths
# > nix build .#nixosConfigurations.test.config.system.build.metadata --print-out-paths
# > incus image import --alias test \
#  /nix/store/8c5f962ngpclwjj9w1xcr48w9rccskqk-tarball/tarball/nixos-image-lxc-metadata-26.05.20260414.4bd9165-x86_64-linux.tar.xz \
#  /nix/store/pxswjzpgw0iwaxvyrvhcbik371mnalmj-nixos-disk-image/nixos.qcow2
# > incus launch test
#
# WILL NOT BE ABLE TO USE SOPS UNTIL HOSTKEY IS ADDED TO AGE FILE.
# Have to set user password, can use `incus shell test` to login to shell
{ self, ... }:
{
  flake.modules.nixos."hosts/dns01" =
    { ... }:
    {
      imports = with self.modules.nixos; [
        # Profiles
        core
        server
        incus-vm
      ];

      # DNS
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
      nixpkgs.hostPlatform = "x86_64-linux";
    };
}
