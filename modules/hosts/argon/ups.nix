# TODO: Clean this up
{ ... }:
{
  flake.modules.nixos."hosts/argon" =
    { pkgs, config, ... }:
    {
      # Sops definitions
      sops.secrets."ups/adminpass" = { };
      sops.secrets."ups/guestpass" = { };

      power.ups = {
        enable = true;
        mode = "netserver";
        openFirewall = true;
        ups."UPS-1" = {
          description = "CyberPower UPS";
          driver = "usbhid-ups";
          port = "auto";
          directives = [
            # "Restore power on AC" BIOS option needs power to be cut a few seconds to work;
            # this is achieved by the offdelay and ondelay directives.

            # in the last stages of system shutdown, "upsdrvctl shutdown" is called to tell UPS that
            # after offdelay seconds, the UPS power must be cut, even if
            # wall power returns.

            # There is a danger that the system will take longer than the default 20 seconds to shut down. 
            # If that were to happen, the UPS shutdown would provoke a brutal system crash.
            # We adjust offdelay, to solve this issue.
            "offdelay = 60"

            # UPS power is now cut regardless of wall power.  After (ondelay minus offdelay) seconds,
            # if wall power returns, turn on UPS power.  The system has now been disconnected for a minimum of (ondelay minus offdelay) seconds,
            # "Restore power on AC" should now power on the system.
            # For reasons described above, ondelay value must be larger than offdelay value.
            # We adjust ondelay, to ensure Restore power on AC option returns to Power Disconnected state.
            "ondelay = 70"

            # set value for battery.charge.low,
            # upsmon initiate shutdown once this threshold is reached.
            "lowbatt = 40"

            # ignore it if the UPS reports a low battery condition
            # without this, system will shutdown only when ups reports lb,
            # not respecting lowbatt option
            "ignorelb"
          ];
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
            actions = [ "set" "fsd" ];
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

      # Service to tell the UPS to cut AC power after a delay
      # This is needed so that the BIOS will restart the server once AC power is restored
      systemd.services.nut-delayed-ups-shutdown = {
        enable = true;
        environment = config.systemd.services.upsmon.environment;
        description = "Initiate delayed UPS shutdown";
        before = [ "umount.target" ];
        wantedBy = [ "final.target" ];
        serviceConfig = {
          Type = "oneshot";
          # need to use '-u root', or else permission denied
          ExecStart = ''${pkgs.nut}/bin/upsdrvctl -u root shutdown'';
        };
        unitConfig = {
          ConditionPathExists = config.power.ups.upsmon.settings.POWERDOWNFLAG;
          DefaultDependencies = "no";
        };
      };
    };
}

