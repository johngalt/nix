{
  config,
  lib,
  ...
}:
let
  cfg = config.custom.graphical.niri;
  homeDir = "/home/${config.custom.hjem.user}";
  matugenDir = ".config/matugen/themes";

  inherit (lib)
    mkIf
    ;
in
{
  config = mkIf (cfg.shell == "dms" && cfg.enable) {
    # Make matugen config file
    # DMS will handle dynamically creating themes off these templates
    custom.hjem.cfg.files.".config/matugen/config.toml".text = ''
      [config]

      [templates.btop]
      input_path = '${homeDir}/.config/matugen/themes/btop.theme'
      output_path = '${homeDir}/.config/btop/themes/matugen.theme'

      [templates.yazi]
      input_path = '${homeDir}/.config/matugen/themes/yazi-theme.toml'
      output_path = '${homeDir}/.config/yazi/theme.toml'

      [templates.vesktop]
      input_path = '${homeDir}/.config/matugen/themes/vesktop.css'
      output_path = '${homeDir}/.config/vesktop/themes/dank-modified.css'

      [templates.helix]
      input_path = '${homeDir}/.config/matugen/themes/helix.toml'
      output_path = '${homeDir}/.config/helix/themes/matugen.toml'

      [templates.zathura]
      input_path = '${homeDir}/.config/matugen/themes/zathura-colors'
      output_path = '~/.config/zathura/zathurarc'
    '';

    # Btop matugen template
    custom.hjem.cfg.files."${matugenDir}/btop.theme".source = ./btop.theme;
    custom.hjem.cfg.files."${matugenDir}/yazi-theme.toml".source = ./yazi-theme.toml;
    custom.hjem.cfg.files."${matugenDir}/vesktop.css".source = ./vesktop.css;
    custom.hjem.cfg.files."${matugenDir}/helix.toml".source = ./helix.toml;
    custom.hjem.cfg.files."${matugenDir}/zathura-colors".source = ./zathura-colors;
  };
}
