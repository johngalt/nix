{
  config,
  lib,
  ...
}:
let
  cfg = config.custom.programs.firefox;

  inherit (lib)
    mkEnableOption
    mkIf
    ;
in
{
  options.custom.programs.firefox = {
    enable = mkEnableOption "Enable Firefox";
  };

  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
    };
    # stylix.targets.firefox.enable = false;
  };
}
