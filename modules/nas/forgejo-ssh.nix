# Forward SSH connections to the git user to the forgejo container
{ ... }:
{
  flake.modules.nixos.nas =
    { pkgs, ... }:
    let
      forwardPort = 2222;
      forwardKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOGzRIvlab3xpOUucc0NyROrtQxXk02s81T08tt8hz66 git@argon";
    in
    {
      # Create a shell script to forward git commands to the forgejo container
      environment.systemPackages = [
        (pkgs.writeShellScriptBin "gitea" ''
          ssh -p ${toString forwardPort} -o StrictHostKeyChecking=no git@127.0.0.1 "SSH_ORIGINAL_COMMAND=\"$SSH_ORIGINAL_COMMAND\" $0 $@"
        '')
      ];
      system.activationScripts.gitealink.text = ''
        mkdir -p /usr/local/bin
        rm /usr/local/bin/gitea || true
        ln -s /run/current-system/sw/bin/gitea /usr/local/bin/gitea
      '';

      # Will create a git user with a shared key to allow SSH connection to the container
      # Forgejo will add user keys that will then pass git requests to the container
      users = {
        users = {
          git = {
            isNormalUser = true;
            group = "git";
            openssh.authorizedKeys.keys = [ forwardKey ];
            password = "";
          };
        };
        groups = {
          git = { };
        };
      };
    };
}
