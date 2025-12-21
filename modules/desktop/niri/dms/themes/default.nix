{
  config,
  lib,
  ...
}:
let
  cfg = config.custom.desktop.niri;
  themeDir = ".config/DankMaterialShell/themes";

  inherit (lib)
    mkIf
    ;
in
{
  config = mkIf (cfg.shell == "dms" && cfg.enable) {
    custom.hjem.cfg = {
      files."${themeDir}/theme_gruvbox_material_soft.json".source = ./theme_gruvbox_material_soft.json;
      files."${themeDir}/theme_gruvbox_material_medium.json".source = ./theme_gruvbox_material_medium.json;
      files."${themeDir}/theme_gruvbox_material_hard.json".source = ./theme_gruvbox_material_hard.json;            
    };
  };
}
