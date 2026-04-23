{ self, ... }:
{
  # Gaming profile. Just an addon profile, does not include anything else
  flake.modules.nixos.gaming =
    { ... }:
    {
      imports = with self.modules.nixos; [
        steam
      ];
    };
}
