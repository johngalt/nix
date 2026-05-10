{ ... }:
{
  flake.modules.nixos.core =
    { private, ... }:
    {
      programs.nh = {
        enable = true;
        flake = "/home/${private.username}/git/nixos";
      };
    };
}
