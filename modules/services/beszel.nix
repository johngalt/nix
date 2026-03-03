{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.services.beszel;

  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    ;
  inherit (lib.types)
    str
    attrsOf
    ;

in
{
  options.custom.services.beszel = {
    enable = mkEnableOption "Enable beszel agent";
    # user = mkOption {
    #   type = str;
    #   description = "User to run beszel-hub";
    #   default = "beszel-agent";
    # };
    environmentFile = mkOption {
      type = lib.types.path;
      description = "Path to environment file used with beszel-agent service";
    };
    environment = mkOption {
      type = attrsOf str;
      description = "Beszel environmental variables";
      default = { };
    };
  };

  config = mkIf cfg.enable {
    ####
    # Remove once PR 461327 is merged
    # https://github.com/NixOS/nixpkgs/pull/461327
    # users.users.${cfg.user} = {
    #   isSystemUser = true;
    #   group = cfg.user;
    # };
    # systemd.services.beszel-agent = {
    #   serviceConfig = {
    #     SupplementaryGroups = lib.optionals config.virtualisation.docker.enable [ "docker" ] ++ [
    #       "messagebus"
    #     ];

    #     DynamicUser = mkForce false;
    #     Group = "beszel-agent";
    #   };
    # };
    # users.groups.beszel-agent = { };
    ####

    services.beszel.agent = {
      enable = true;
      openFirewall = true;
      environmentFile = cfg.environmentFile;
      environment = cfg.environment;
      extraPath = pkgs.intel-gpu-tools;
    };
  };
}
