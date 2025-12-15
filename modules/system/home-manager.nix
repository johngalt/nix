# NOT USING ANYMORE IN FAVOR OF HJEM
# KEEPING MODULE FOR REFERENCE
{
  config,
  private,
  inputs,
  lib,
  options,
  ...
}:
let
  cfg = config.custom.hm;

  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    mkAliasDefinitions
    ;

  inherit (lib.types)
    listOf
    package
    str
    attrs
    ;
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  options.custom.hm = {
    enable = mkEnableOption "Enable home-manager module";
    user = mkOption {
      description = "Username for home-manager user";
      type = str;
      default = null;
    };
    extraPackages = mkOption {
      description = "Extra packages to install via home-manager";
      type = listOf package;
      default = [ ];
    };
    cfg = mkOption {
      type = attrs;
      description = "Shortcut to home-manager user attribute set";
      default = { };
    };
  };

  config = mkIf cfg.enable {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = { inherit private inputs; };
      backupFileExtension = "backup";

      # Creating shortcut custom.hm.cfg -> home-manager.users.USER
      # Don't need to pass username throughout modules and makes it easier to reference
      users.${cfg.user} = mkAliasDefinitions options.custom.hm.cfg;
    };

    # Reference alias as above
    custom.hm.cfg.home = {
      packages = cfg.extraPackages;
      stateVersion = "25.11";
    };
  };
}
