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
  # Set global custom option to control enabling all elements of the graphical module
  options.custom.graphical = {
    enable = mkEnableOption "Enable graphical configurations";
  };
}
