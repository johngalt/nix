{ ... }:
{
  flake.modules.nixos.steam =
    { pkgs, ... }:
    {
      # Adwiata theme installer for Steam
      environment.systemPackages = with pkgs; [
        adwsteamgtk
      ];
      programs.steam = {
        enable = true;
        # Proton-GE
        extraCompatPackages = with pkgs; [
          proton-ge-bin
        ];
        protontricks.enable = true;
      };

      # Set home directories to persist if enabled
      custom.system.impermanence = {
        persistHome.directories = [
          ".local/share/Steam"
          ".steam"
        ];
      };
    };
}
