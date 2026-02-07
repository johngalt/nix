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
    programs.steam = {
      enable = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
      protontricks.enable = true;
    };
    programs.gamemode.enable = true;
  };
}
