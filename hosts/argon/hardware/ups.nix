{
  config,
  pkgs,
  lib,
  ...
}:
let 
  # Discord notification
  notifyCommand = pkgs.writeShellApplication {
    name = "upsmon-notify";
    runtimeInputs = [
      pkgs.curl
    ];
    text =
      ''
        curl -H "Content-Type: application/json" -X POST -d '{"content":"'"$*"'"}' "$(cat ${config.sops.secrets."ups/notifyurl".path})"
      '';
  };
in 
{
  # Sops definitions
  sops.secrets."ups/adminpass" = { };
  sops.secrets."ups/guestpass" = { };
  sops.secrets."ups/notifyurl" = { };
  
  power.ups = {
    enable = true;
    mode = "netserver";
    openFirewall = true;
    ups."UPS-1" = {
      description = "CyberPower UPS";
      driver = "usbhid-ups";
      port = "auto";
    };
    upsd = {    
      listen = [
        {
          address = "0.0.0.0";
          port = 3493;
        }
      ];
    };
    users = {
      "admin" = {
        passwordFile = config.sops.secrets."ups/adminpass".path;
        actions = [
          "set"
          "fsd"
        ];
        instcmds = [ "all" ];
        upsmon = "primary";
      };
      "guest" = {
        passwordFile = config.sops.secrets."ups/guestpass".path;
        upsmon = "secondary";
      };
    };
    upsmon = {
      monitor."UPS-1" = {
        system = "UPS-1@localhost";
        powerValue = 1;
        user = "admin";
        passwordFile = config.sops.secrets."ups/adminpass".path;
        type = "primary";
      };
      settings = {
        # This configuration file declares how upsmon is to handle
        # NOTIFY events.

        # POWERDOWNFLAG and SHUTDOWNCMD is provided by NixOS default
        # values

        # values provided by ConfigExamples 3.0 book
        NOTIFYMSG = [
          [ "ONLINE" ''"UPS %s: On line power."'' ]
          [ "ONBATT" ''"UPS %s: On battery."'' ]
          [ "LOWBATT" ''"UPS %s: Battery is low."'' ]
          [ "REPLBATT" ''"UPS %s: Battery needs to be replaced."'' ]
          [ "FSD" ''"UPS %s: Forced shutdown in progress."'' ]
          [ "SHUTDOWN" ''"Auto logout and shutdown proceeding."'' ]
          [ "COMMOK" ''"UPS %s: Communications (re-)established."'' ]
          [ "COMMBAD" ''"UPS %s: Communications lost."'' ]
          [ "NOCOMM" ''"UPS %s: Not available."'' ]
          [ "NOPARENT" ''"upsmon parent dead, shutdown impossible."'' ]
        ];
        NOTIFYFLAG = [
          [ "ONLINE" "SYSLOG+WALL+EXEC" ]
          [ "ONBATT" "SYSLOG+WALL+EXEC" ]
          [ "LOWBATT" "SYSLOG+WALL+EXEC" ]
          [ "REPLBATT" "SYSLOG+WALL+EXEC" ]
          [ "FSD" "SYSLOG+WALL+EXEC" ]
          [ "SHUTDOWN" "SYSLOG+WALL+EXEC" ]
          [ "COMMOK" "SYSLOG+WALL+EXEC" ]
          [ "COMMBAD" "SYSLOG+WALL+EXEC" ]
          [ "NOCOMM" "SYSLOG+WALL+EXEC" ]
          [ "NOPARENT" "SYSLOG+WALL+EXEC" ]
        ];
        NOTIFYCMD = "${lib.getExe' notifyCommand "upsmon-notify"}";

        # every RBWARNTIME seconds, upsmon will generate a replace
        # battery NOTIFY event
        RBWARNTIME = 216000;
        # every NOCOMMWARNTIME seconds, upsmon will generate a UPS
        # unreachable NOTIFY event
        NOCOMMWARNTIME = 300;
        # after sending SHUTDOWN NOTIFY event to warn users, upsmon
        # waits FINALDELAY seconds long before executing SHUTDOWNCMD
        # Some UPS's don't give much warning for low battery and will
        # require a value of 0 here for aq safe shutdown.
        FINALDELAY = 0;  
      };
    };
  };
}
