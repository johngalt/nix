# Beszel agent service to automatically send stats to the beszel hub
{ ... }:
{
  flake.modules.nixos.beszel =
    { config, lib, private, ... }:
    let
      cfg = config.custom.services.beszel;

      inherit (lib) mkOption;
      inherit (lib.types) attrs;
    in
    {
      # Custom option will allow host-specific settings
      options.custom.services.beszel = {
        extraEnv = mkOption {
          type = attrs;
          description = "Extra environmental variables to pass to the beszel agent";
          default = { };
        };
      };

      config = {
        # Initialize the secrets for the agent
        sops.secrets."beszel/sshKey" = { };
        sops.secrets."beszel/universalToken" = { };
        sops.templates."beszel-agent-config".content = ''
          HUB_URL=https://beszel.${private.domain}
          KEY=${config.sops.placeholder."beszel/sshKey"}
          TOKEN=${config.sops.placeholder."beszel/universalToken"}
        '';

        services.beszel.agent = {
          enable = true;
          openFirewall = true;
          smartmon.enable = true;
          environmentFile = config.sops.templates."beszel-agent-config".path;
          environment = cfg.extraEnv;
        };
      };
    };
}
