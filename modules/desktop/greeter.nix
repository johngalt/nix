{ ... }:
{
  flake.modules.nixos.greeter =
    { config, pkgs, lib, ... }:
    let
      # use nixpkgs displayManager module to get desktop session files to load from
      sessionFiles = "${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
    in
    {
      services.greetd = {
        enable = true;
        useTextGreeter = true;
        settings = {
          default_session = {
            command = "${lib.getExe pkgs.tuigreet} --asterisks --remember --time --sessions ${sessionFiles}";
            user = "greeter";
          };
        };
      };

      # persist preservation cache dir
      custom.system.preservation.extraCacheDirectories = [ "/var/cache/tuigreet" ];

      # lets make the console prettier
      console = {
        colors = [
          "282828"
          "ea6962"
          "a9b665"
          "d8a657"
          "7daea3"
          "d3869b"
          "89b482"
          "d4be98"
          "928374"
          "ea6962"
          "a9b665"
          "d8a657"
          "7daea3"
          "d3869b"
          "89b482"
          "ddc7a1"
        ];
      };
    };
}
