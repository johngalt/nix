{ ... }:
{
  flake.modules.nixos.devenv =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        devenv
      ];
      programs.direnv = {
        enable = true;
        silent = true;
      };
    };
}
