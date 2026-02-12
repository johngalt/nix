{
  config,
  ...
}:
{
  # Sops definitions
  sops.secrets."ups/guestpass" = { };
  
  power.ups = {
    enable = true;
    mode = "netclient";
    openFirewall = true;
    upsmon = {
      monitor."UPS-1" = {
        system = "UPS-1@argon.gudhak.home";
        powerValue = 1;
        user = "guest";
        passwordFile = config.sops.secrets."ups/guestpass".path;
        type = "secondary";
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
          [ "ONLINE" "SYSLOG+WALL" ]
          [ "ONBATT" "SYSLOG+WALL" ]
          [ "LOWBATT" "SYSLOG+WALL" ]
          [ "REPLBATT" "SYSLOG+WALL" ]
          [ "FSD" "SYSLOG+WALL" ]
          [ "SHUTDOWN" "SYSLOG+WALL" ]
          [ "COMMOK" "SYSLOG+WALL" ]
          [ "COMMBAD" "SYSLOG+WALL" ]
          [ "NOCOMM" "SYSLOG+WALL" ]
          [ "NOPARENT" "SYSLOG+WALL" ]
        ];
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
