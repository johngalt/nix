{
  private,
  pkgs,
  ...
}:
{
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
    profiles.server.enable = true;
    services.scrutiny.enable = true;
  };
}
