{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.programs.steam;
  inherit (lib)
    mkEnableOption
    mkIf
    ;
in
{
  options.custom.programs.steam = {
    enable = mkEnableOption "Enable Steam";
  };

  config = mkIf cfg.enable {
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
    # programs.gamemode.enable = true;
  };
}
