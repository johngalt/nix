{ ... }:
{
  flake.modules.nixos.renovate =
    { private, config, ... }:
    {
      # Initialize secrets
      sops.secrets."renovate/github_key" = { };
      sops.secrets."renovate/renovate_key" = { };

      services.renovate = {
        enable = true;
        credentials = {
          RENOVATE_TOKEN = config.sops.secrets."renovate/renovate_key".path;
          GITHUB_COM_TOKEN = config.sops.secrets."renovate/github_key".path;
        };
        settings = {
          endpoint = "https://forge.${private.domain}/api/v1";
          gitAuthor = "Renovate Bot <renovate-bot@${private.domain}>";
          platform = "forgejo";
          onboardingConfigFileName = "renovate.json";
          autodiscover = true;
          optimizeForDisabled = true;
          persistRepoData = true;
        };
        schedule = "*-*-* 00/2:00:00";
      };

      # Set directories to persist
      custom.system.impermanence = {
        extraDirectories = [
          "/var/lib/private/renovate"
          "/var/cache/private/renovate"
        ];
      };
    };
}
