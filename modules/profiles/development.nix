{ self, ... }:
{
  # Development profile. Just an addon profile, does not include anything else
  flake.modules.nixos.development =
    { ... }:
    {
      imports = with self.modules.nixos; [
        devenv
      ];
    };
}
