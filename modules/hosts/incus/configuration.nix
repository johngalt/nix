{ self, ... }:
{
  flake.modules.nixos."hosts/incus" =
    { ... }:
    {
      imports = with self.modules.nixos; [
        # Profiles
        base
        server

        # System Modules
        incus

        # Service Modules
        scrutiny
      ];
    };
}
