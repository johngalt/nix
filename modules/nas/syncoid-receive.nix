{ ... }:
{
  flake.modules.nixos.nas =
    { config, pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        sanoid
        zstd # Compression
        mbuffer # Network buffer during zfs send/receive
      ];

      sops.secrets."syncoid/userPass".neededForUsers = true;
      
      # Creates syncoid user to use ZFS receive
      # Syncoid on remote hosts will use ssh private key to connect
      # Had to imperatively `allow` access for this user to the tank/mirror dataset
      users.users.syncoid = {
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets."syncoid/userPass".path;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPLsOp1UXJ14Wc4fz5nWm/C2Y7G3ehYHry5aqfW9adGj syncoid"
        ];
      };
    };
}
