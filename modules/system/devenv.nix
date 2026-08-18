{ ... }:
{
  flake.modules.nixos.devenv =
    { pkgs, ... }:
    {
      # TODO: fall back to nixpkgs once devenv updated to 2.2
      environment.systemPackages = with pkgs; [
        devenv
      ];

      # TODO: No longer needed?
      programs.fish.interactiveShellInit = "devenv hook fish | source";
    };
}
