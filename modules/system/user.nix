{
  config,
  pkgs,
  private,
  ...
}:
let 
  # Helper functions for adding extra groups
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
  # Extra groups to add to user if the groups exist
  extraGroups = [
    "wheel"
  ]
  ++ ifTheyExist [
    "networkmanager"
    "docker"
    "video"
    "render"
  ];
in
{
  config = {
    # User settings
    sops.secrets."userpass/${private.username}".neededForUsers = true;

    users.mutableUsers = false;
    users.users = {
      ${private.username} = {
        isNormalUser = true;
        inherit extraGroups;
        shell = pkgs.fish;
        hashedPasswordFile = config.sops.secrets."userpass/${private.username}".path;
        openssh.authorizedKeys.keys = [
          private.key
        ];
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
