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
    ./plasma
    ./audio.nix
    ./fonts.nix
    ./security.nix
  ];

  options.custom.desktop = {
    enable = mkEnableOption "Enable global desktop configurations";
  };
}
