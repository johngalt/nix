{
  config,
  private,
  ...
}:
let
  # Pulling user/key from private flake
  myUser = private.username;
  pubKey = private.key;
in
{
  sops.secrets."userpass/${myUser}".neededForUsers = true;

  users = {
    mutableUsers = false;
    users = {
      ${myUser} = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        # TODO: REPLACE WITH LINK TO SHELL MODULE PACKAGE
        # shell = pkgs.fish;
        hashedPasswordFile = config.sops.secrets."userpass/${myUser}".path;
        openssh.authorizedKeys.keys = [
          pubKey
        ];
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
}
