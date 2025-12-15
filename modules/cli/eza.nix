{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.custom.cli.eza;

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
  options.custom.cli.eza = {
    enable = mkEnableOption "Enable eza, an ls replacement";
    theme = mkOption {
      type = str;
      description = "Theme to use for eza";
      default = "catppuccin";
    };
  };

  config = mkIf cfg.enable {
    # Using systemPackages so its available as root as well
    environment.systemPackages = with pkgs; [
      eza
      eza-themes # Custom package from eza-themes repository
    ];
    custom.hjem.cfg = {
      files.".config/eza/theme.yml".source = "${pkgs.eza-themes}/share/eza-themes/${cfg.theme}.yml";
    };
  };
}
