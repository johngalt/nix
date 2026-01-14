{
  config,
  lib,
  pkgs,
  ...
}:
let 
  cfg = config.custom.programs.zed;
  inherit (lib)
    mkEnableOption
    mkIf
    ;
in 
{
  options.custom.programs.zed = {
    enable = mkEnableOption "Enable Zed editor";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      zed-editor
    ];

    # Dynamic library support
    programs.nix-ld.enable = true;

    # TODO: declaritive zed settings
    custom.hjem.cfg = {
    };
  };
}
