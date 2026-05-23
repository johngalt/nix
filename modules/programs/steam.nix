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
    };
}
