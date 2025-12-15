{
  lib,
  config,
  ...
}:
let
  cfg = config.custom.system.docker;

  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    optionalAttrs
    ;
  inherit (lib.types)
    str
    nullOr
    listOf
    ;
in
{
  options.custom.system.docker = {
    enable = mkEnableOption "Enable docker module";
    customUser = mkOption {
      description = "Create separate docker user";
      type = nullOr str;
      default = null;
    };
    customUserGroups = mkOption {
      description = "Extra groups to add custom docker user to";
      type = listOf str;
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.docker.autoPrune.enable = lib.mkDefault true;

    users.users = optionalAttrs (cfg.customUser != null) {
      ${cfg.customUser} = {
        isSystemUser = true;
        group = "docker";
        extraGroups = cfg.customUserGroups;
      };
    };
  };
}
