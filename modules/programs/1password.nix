{
  config,
  lib,
  private,
  ...
}:

let
  cfg = config.custom.programs._1password;

  inherit (lib)
    mkEnableOption
    mkIf
    ;
in
{
  options.custom.programs._1password = {
    enable = mkEnableOption "Enable 1password password manager";
  };

  config = mkIf cfg.enable {
    programs._1password.enable = true;
    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = [ private.username ];
    };
  };
}
