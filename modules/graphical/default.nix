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
    ./quickshell
    ./audio.nix
    ./fonts.nix
    ./greeter.nix
    ./portals.nix
  ];

  options.custom.graphical = {
    enable = mkEnableOption "Enable graphical configurations";
  };
}
