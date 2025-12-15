{
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    ;
in
{
  imports = [
    ./niri
    ./plasma.nix
    ./audio.nix
    ./fonts.nix
    ./security.nix
    ./mime.nix
  ];

  options.custom.desktop = {
    enable = mkEnableOption "Enable global desktop configurations";
  };
}
