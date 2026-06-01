{ ... }:
{
  flake.modules.nixos.dms =
    { config, ... }:
    let
      homeDir = config.hj.directory;
      matugenThemeDir = ".config/matugen/themes";
    in
    {
      hj = {
        # Create config file for matugen to generate dynamic theme files with dms
        files.".config/matugen/config.toml".text = ''
          [config]

          [templates.btop]
          input_path = '${homeDir}/.config/matugen/themes/btop.theme'
          output_path = '${homeDir}/.config/btop/themes/matugen.theme'

          [templates.vesktop]
          input_path = '${homeDir}/.config/matugen/themes/vesktop.css'
          output_path = '${homeDir}/.config/vesktop/themes/dank-modified.css'

          [templates.zathura]
          input_path = '${homeDir}/.config/matugen/themes/zathura-colors'
          output_path = '${homeDir}/.config/zathura/zathurarc'
        '';
        # Now to put the theme templates into the matugen template directory
        files."${matugenThemeDir}/btop.theme".source = ./matugen/btop.theme;
        # files."${matugenThemeDir}/yazi-theme.toml".source = ./matugen/yazi-theme.toml; # Not used
        files."${matugenThemeDir}/vesktop.css".source = ./matugen/vesktop.css;
        # files."${matugenThemeDir}/helix.toml".source = ./matugen/helix.toml; # Not used
        files."${matugenThemeDir}/zathura-colors".source = ./matugen/zathura-colors;
      };
    };
}
