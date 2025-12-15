{
  config,
  lib,
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
    # gnupg agent; plasma module installs pinentry if enabled
    programs = {
      gnupg.agent = {
        enable = true;
      };
    };
  };
}
