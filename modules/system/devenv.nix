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

      # Set home directories to persist if enabled
      custom.system.impermanence = {
        persistHome.directories = [
          ".local/share/devenv"
          ".local/share/direnv"
        ];
      };
    };
}
