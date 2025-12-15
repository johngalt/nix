{
  config,
  lib,
  inputs,
  options,
  ...
}:
let
  cfg = config.custom.hjem;
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    mkAliasDefinitions
    ;
  inherit (lib.types)
    str
    nullOr
    attrs
    listOf
    package
    ;
in
{
  imports = [
    inputs.hjem.nixosModules.default
  ];

  options.custom.hjem = {
    enable = mkEnableOption "Enable hjem for home management";
    user = mkOption {
      type = nullOr str;
      description = "User to manage via hjem";
      default = null;
    };
    extraPackages = mkOption {
      description = "Extra packages to install via home-manager";
      type = listOf package;
      default = [ ];
    };
    cfg = mkOption {
      type = attrs;
      description = "Shortcut to hjem user attribute set";
      default = { };
    };
  };
  config = mkIf cfg.enable {
    hjem = {
      # Hjem rum additional modules
      extraModules = [
        inputs.hjem-rum.hjemModules.default
      ];
      # Enable clobber by default to overwrite non-managed files
      clobberByDefault = true;
      # Create custom config option as an alias so I don't have to pass my username to all my modules
      # It will be passed once to load the hjem module
      users.${cfg.user} = mkAliasDefinitions options.custom.hjem.cfg;
    };
    # Set baseline hjem options for user
    custom.hjem.cfg = {
      user = cfg.user;
      directory = "/home/${cfg.user}";
      packages = cfg.extraPackages;
    };
  };
}
