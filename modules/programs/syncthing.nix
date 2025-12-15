{
  config,
  pkgs,
  lib,
  private,
  ...
}:
let
  cfg = config.custom.programs.syncthing;

  inherit (lib)
    mkEnableOption
    mkIf
    ;

in
{
  options.custom.programs.syncthing = {
    enable = mkEnableOption "Enable syncthing with default settings";
  };

  config = mkIf cfg.enable {
    sops.secrets."syncthing/cert" = { };
    sops.secrets."syncthing/key" = { };

    services.syncthing = {
      enable = true;
      user = private.username;
      group = "users";
      dataDir = "/home/${private.username}";
      overrideFolders = true;
      overrideDevices = true;
      cert = config.sops.secrets."syncthing/cert".path;
      key = config.sops.secrets."syncthing/key".path;
      openDefaultPorts = true;
      settings = {
        folders = {
          "/home/${private.username}/Drive" = {
            label = "Drive";
            id = "jrsnq-gumkg";
            devices = [
              "argon"
            ];
          };
        };
        devices = {
          argon = {
            addresses = [
              "tcp://argon.gudhak.home:22000"
            ];
            id = private.syncthingId;
          };
        };
      };
    };

    # Syncthing tray user service
    environment.systemPackages = with pkgs; [
      syncthingtray-minimal
    ];

    systemd.user.services.syncthingtray = {
      name = "syncthingtray";
      description = "Syncthing tray service";
      path = [ pkgs.syncthingtray-minimal ];
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      script = ''
        ${pkgs.syncthingtray-minimal}/bin/syncthingtray --wait
      '';
    };
  };
}
