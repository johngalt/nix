{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.desktop;
  inherit (lib)
    mkIf
    ;
in
{
  config = mkIf cfg.enable {
    # Font packages and fontconfig
    fonts = {
      packages = with pkgs; [
        corefonts
        noto-fonts
        cascadia-code
        noto-fonts-color-emoji
      ];
      fontconfig.useEmbeddedBitmaps = true;
      fontconfig.defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "Cascadia Mono" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
