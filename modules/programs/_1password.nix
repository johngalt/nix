{
  config,
  lib,
  ...
}:

let 
  cfg = config.custom.programs._1password;

  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    ;
  inherit (lib.types)
    str
    listOf
    ;

in 
{
  options.custom.programs._1password = {
    enable = mkEnableOption "Enable 1password password manager";
    polkitUsers = mkOption {
      type = listOf str;
      description = "List of users to add to polkit policy";
    };
  };

  config = mkIf cfg.enable {
    programs._1password.enable = true;
    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = cfg.polkitUsers;
    };
  };
}
