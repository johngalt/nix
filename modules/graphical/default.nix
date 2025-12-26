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
    ./dms-greeter
    ./audio.nix
    ./fonts.nix
  ];

  options.custom.graphical = {
    enable = mkEnableOption "Enable graphical configurations";
  };
}
