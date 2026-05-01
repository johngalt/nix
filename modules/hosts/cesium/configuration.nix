{ self, ... }:
{
  flake.modules.nixos."hosts/cesium" =
    { ... }:
    {
      imports = with self.modules.nixos; [
        # Profiles
        base
        server

        # System Modules
        impermanence

        # Service Modules
        scrutiny
        technitium
        renovate
      ];

      config = {
        custom = {
          system = {
            impermanence = {
              rootFilesystem = "/dev/disk/by-partlabel/disk-main-root";
              persistPath = "/persist";
            };
          };
        };
      };
    };
}
