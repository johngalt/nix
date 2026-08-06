{ self, ... }:
{
  # Development profile. Just an addon profile, does not include anything else
  flake.modules.nixos.development =
    { pkgs, ... }:
    {
      imports = with self.modules.nixos; [
        devenv
        claude
      ];
      config = {
        environment.systemPackages = with pkgs; [
          # Some Nix utilities
          nixpkgs-track
          hydra-check
        ];
      };
    };
}
