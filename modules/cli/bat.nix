{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.cli.bat;

  # Set theme for bat
  batTheme = "gruvbox-dark";

  inherit (lib)
    mkEnableOption
    mkIf
    ;
in
{
  options.custom.cli.bat = {
    enable = mkEnableOption "Enable bat, a cat replacement";
  };

  config = mkIf cfg.enable {
    programs.bat = {
      enable = true;
      # Bat plugins
      extraPackages = with pkgs.bat-extras; [
        batdiff
        batman
        prettybat
      ];
      settings = {
        italic-text = "always";
        theme = batTheme;
      };
    };

    # Set alias to replace cat
    environment.shellAliases = {
      cat = "bat";
    };
  };
}
