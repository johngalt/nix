{ inputs, self, ... }:
{
  flake.modules.nixos."hosts/atlantis" =
    { hostConfig, ... }:
    {
      imports = [
        inputs.nixos-wsl.nixosModules.default
        self.modules.nixos.base
      ];

      config = {
        wsl = {
          enable = true;
          defaultUser = "taylor";
        };
        networking = {
          hostName = hostConfig.name;
          domain = hostConfig.domain;
        };
        nixpkgs.hostPlatform = "x86_64-linux";
      };
    };
}
