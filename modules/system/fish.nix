{
  config,
  lib,
  pkgs,
  ...
}:
let 
  cfg = config.custom.system.fish;
  inherit (lib)
    mkEnableOption
    mkIf
    ;
in 
{
  options.custom.system.fish = {
    enable = mkEnableOption "Enable fish shell";
  };

  config = mkIf cfg.enable {
    programs.fish = {
      enable = true;
    };

    # Fish plugins
    environment.systemPackages = with pkgs.fishPlugins; [
      fzf-fish
      pure
    ];
  };
}
