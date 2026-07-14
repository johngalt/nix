{ ... }:
{
  flake.modules.nixos.devenv =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        devenv
      ];

      programs.fish.interactiveShellInit = "devenv hook fish | source";

      # programs.direnv = {
      #   enable = true;
      #   silent = true;
      # };
    };
}
