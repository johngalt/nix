{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.custom.cli.eza;

  # Theme for eza
  ezaTheme = "gruvbox-dark";

  inherit (lib)
    mkEnableOption
    mkIf
    ;
in
{
  options.custom.cli.eza = {
    enable = mkEnableOption "Enable eza, an ls replacement";
  };

  config = mkIf cfg.enable {
    # Using systemPackages so its available as root as well
    environment.systemPackages = with pkgs; [
      eza
      eza-themes # Custom package from eza-themes repository
    ];

    environment.shellAliases = {
      ls = "eza --icons=auto";
      ll = "eza -l -a --icons=auto";
      tree = "eza --tree --git-ignore --icons=auto";
    };

    custom.hjem.cfg = {
      files.".config/eza/theme.yml".source = "${pkgs.eza-themes}/share/eza-themes/${ezaTheme}.yml";
    };
  };
}
