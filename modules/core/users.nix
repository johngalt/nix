{ ... }:
{
  flake.modules.nixos.core =
    { private, pkgs, config, ... }:
    let
      myUser = private.username;
      myPubkey = private.key;

      # Function to add user to extra groups if these groups exist for the host
      ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
      extraGroups = ifTheyExist [
        "wheel"
        "networkmanager"
        "docker"
        "video"
        "render"
        "input"
      ];
    in
    {
      # Secret needs to be available before Nix creates users
      sops.secrets."userpass/${myUser}".neededForUsers = true;
      users = {
        mutableUsers = false;
        users = {
          ${myUser} = {
            isNormalUser = true;
            inherit extraGroups;
            shell = pkgs.fish;
            hashedPasswordFile = config.sops.secrets."userpass/${myUser}".path;
            # initialHashedPassword = "$y$j9T$yYBXBprRkerd0LLg6WTJU.$iRtDta/kDy.zvLC.OoRTKtuv8HGdVdBtZUylSxzwSR4";
            openssh.authorizedKeys.keys = [ myPubkey ];
          };
        };
      };
      # Disable sudo lecture since root filesystem is wiped on each boot
      security.sudo = {
        wheelNeedsPassword = false;
        extraConfig = ''
          Defaults lecture = never
        '';
      };
    };
}
