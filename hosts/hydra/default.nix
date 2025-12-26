{
  private,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware
  ];

  # SOPS definitions
  # Beszel
  sops.secrets."beszel/sshkey" = { };
  sops.secrets."beszel/hydratoken" = { };
  sops.templates."beszel-agent".content = ''
    HUB_URL=https://beszel.${private.domain}
    KEY=${config.sops.placeholder."beszel/sshkey"}
    TOKEN=${config.sops.placeholder."beszel/hydratoken"}
  '';
  # Renovate
  sops.secrets."renovate/github_key" = { };
  sops.secrets."renovate/renovate_key" = { };
  # Actions runner for gitea/forgejo
  sops.secrets."act-runner/token" = { };

  # Host-specific services
  services.renovate = {
    enable = true;
    credentials = {
      RENOVATE_TOKEN = config.sops.secrets."renovate/renovate_key".path;
      GITHUB_COM_TOKEN = config.sops.secrets."renovate/github_key".path;
    };
    settings = {
      endpoint = "https://forge.${private.domain}/api/v1";
      gitAuthor = "Renovate Bot <renovate-bot@${private.domain}>";
      platform = "gitea";
      onboardingConfigFileName = "renovate.json";
      autodiscover = true;
      optimizeForDisabled = true;
      persistRepoData = true;
    };
    schedule = "*-*-* 00/2:00:00";
  };

  services.gitea-actions-runner = {
    package = pkgs.forgejo-runner;
    instances = {
      hydra = {
        enable = true;
        labels = [
          "debian-latest:docker://node:18-bullseye"
          "ubuntu-latest:docker://node:18-bullseye"
          #"native:host"
        ];
        name = config.networking.hostName;
        tokenFile = config.sops.secrets."act-runner/token".path;
        url = "https://forge.${private.domain}";
      };
    };
  };

  # Custom module settings
  custom = {
    profiles.base.enable = true;
    system.docker = {
      enable = true;
      customUser = "docker";
    };
    services = {
      beszel = {
        enable = true;
        environmentFile = config.sops.templates."beszel-agent".path;
      };
    };
  };

  networking.hostName = "hydra";
  networking.domain = private.domain;
  networking.useDHCP = true;
}
