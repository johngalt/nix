{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.cli.bat;
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    ;
  inherit (lib.types)
    str
    ;
in
{
  options.custom.cli.bat = {
    enable = mkEnableOption "Enable bat, a cat replacement";
    theme = mkOption {
      type = str;
      description = "Theme to use for bat";
      default = "ansi"; # Just use terminal colors as default
    };
    enableAliases = mkEnableOption "Enable shell aliases for bat" // {
      default = true;
    };
  };

  config = mkIf cfg.enable {
    programs.bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [
        batdiff
        batman
        prettybat
      ];
      settings = {
        italic-text = "always";
        theme = cfg.theme;
      };
    };

    environment.shellAliases = mkIf cfg.enableAliases {
      cat = "bat";
    };
  };
}
