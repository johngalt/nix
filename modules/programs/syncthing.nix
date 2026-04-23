{ ... }:
{
  flake.modules.nixos.syncthing =
    { private, pkgs, config, ... }:
    let
      cert = config.sops.secrets."syncthing/cert".path;
      key = config.sops.secrets."syncthing/key".path;
      folderID = "jrsnq-gumkg";
      deviceID = private.syncthingId;
    in
    {
      # Initialize the secrets to use with sops
      sops.secrets."syncthing/cert" = { };
      sops.secrets."syncthing/key" = { };

      # Syncthing bakground service
      services.syncthing = {
        inherit cert key;
        enable = true;
        user = config.hj.user;
        group = "users";
        dataDir = config.hj.directory;
        overrideFolders = true;
        overrideDevices = true;
        openDefaultPorts = true;
        settings = {
          folders = {
            "${config.hj.directory}/Drive" = {
              label = "Drive";
              id = folderID;
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
              id = deviceID;
            };
          };
        };
      };

      # Syncthing tray user service
      environment.systemPackages = with pkgs; [
        syncthingtray-minimal
      ];

      # User service to autostart syncthing tray with graphical environment
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

      # Set home directories to persist if enabled
      custom.system.impermanence = {
        persistHome.directories = [
          ".config/syncthing"
          "Drive"
        ];
        persistHome.files = [
          ".config/syncthingtray.ini"
        ];
      };
    };
}
