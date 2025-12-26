{
  config,
  private,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware # Host hardware configuration
  ];

  # Sops
  # Beszel secrets
  sops.secrets."beszel/sshkey" = { };
  sops.secrets."beszel/incustoken" = { };
  sops.templates."beszel-agent".content = ''
    HUB_URL=https://beszel.${private.domain}
    KEY=${config.sops.placeholder."beszel/sshkey"}
    TOKEN=${config.sops.placeholder."beszel/incustoken"}
  '';

  # Enable incus for VM management
  virtualisation.incus = {
    enable = true;
    package = pkgs.incus;
    ui.enable = true;
  };
  # Add incus-admin group to user for management
  users.users.${private.username}.extraGroups = [ "incus-admin" ];

  # Custom module settings
  custom = {
    profiles.base.enable = true;
    services = {
      beszel = {
        enable = true;
        environmentFile = config.sops.templates."beszel-agent".path;
      };
    };
  };
}
