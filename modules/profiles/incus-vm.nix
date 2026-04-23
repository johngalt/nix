{ ... }:
{
  flake.modules.nixos.incus-vm =
    { modulesPath, hostConfig, ... }:
    {
      imports = [
        (modulesPath + "/virtualisation/incus-virtual-machine.nix")
      ];

      config = {
        networking = {
          hostName = hostConfig.name;
          firewall.enable = true;
          useDHCP = true;
        };

        nixpkgs.hostPlatform = "x86_64-linux";
      };
    };
}
