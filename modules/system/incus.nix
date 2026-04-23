{ ... }:
{
  flake.modules.nixos.incus =
    { pkgs, private, ... }:
    {
      virtualisation.incus = {
        enable = true;
        package = pkgs.incus; # Override default incus-lts
        ui = {
          enable = true;
          package = pkgs.incus-ui-canonical;
        };
        preseed = {
          # Stuff
        };
      };

      # Add my user to the incus-admin group
      users.users.${private.username}.extraGroups = [ "incus-admin" ];
    };
}
