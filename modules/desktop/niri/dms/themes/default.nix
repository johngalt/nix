{
  config,
  lib,
  ...
}:
let
  cfg = config.custom.desktop.niri;
  homeDir = "/home/${config.custom.hjem.user}";

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
    '';

    # Btop matugen template
    custom.hjem.cfg.files.".config/matugen/themes/btop.theme".source = ./btop.theme;
  };
}
