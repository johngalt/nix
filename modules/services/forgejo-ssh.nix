{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.services.forgejo-ssh;
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    ;
  inherit (lib.types)
    str
    port
    ;
in
{
  options.custom.services.forgejo-ssh = {
    enable = mkEnableOption "Enable ssh passthru for gitea/forgejo running in docker container";
    sshKey = mkOption {
      type = str;
      description = "Public key used to authenticate with gitea/forgejo internal ssh";
    };
    port = mkOption {
      type = port;
      description = "Port used to connect to gitea/forgejo internal ssh server";
      default = 2222;
    };
  };
  config = mkIf cfg.enable {
    # Bash script to forward git ssh requests
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "gitea" ''
        ssh -p ${toString cfg.port} -o StrictHostKeyChecking=no git@127.0.0.1 "SSH_ORIGINAL_COMMAND=\"$SSH_ORIGINAL_COMMAND\" $0 $@"
      '')
    ];
    system.activationScripts.gitealink.text = ''
      mkdir -p /usr/local/bin
      rm /usr/local/bin/gitea || true
      ln -s /run/current-system/sw/bin/gitea /usr/local/bin/gitea
    '';

    users = {
      users = {
        git = {
          isNormalUser = true;
          group = "git";
          openssh.authorizedKeys.keys = [
            cfg.sshKey
          ];
          password = "";
        };
      };
      groups = {
        git = { };
      };
    };
  };
}
