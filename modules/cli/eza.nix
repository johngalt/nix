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
    nullOr
    ;
in
{
  options.custom.cli.eza = {
    enable = mkEnableOption "Enable eza, an ls replacement";
    theme = mkOption {
      type = nullOr str;
      description = "Theme to use for eza";
      default = null;
    };
    enableAliases = mkEnableOption "Enable shell aliases for eza" // {
      default = true;
    };
  };

  config = mkIf cfg.enable {
    # Using systemPackages so its available as root as well
    environment.systemPackages = with pkgs; [
      eza
      eza-themes # Custom package from eza-themes repository
    ];

    environment.shellAliases = mkIf cfg.enableAliases {
      ls = "eza --icons=auto";
      ll = "eza -l -a --icons=auto";
      tree = "eza --tree --git-ignore --icons=auto";
    };

    custom.hjem.cfg = mkIf (!isNull cfg.theme) {
      files.".config/eza/theme.yml".source = "${pkgs.eza-themes}/share/eza-themes/${cfg.theme}.yml";
    };
  };
}
