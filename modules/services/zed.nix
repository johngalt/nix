{ ... }:
{
  flake.modules.nixos.zed =
    { config, pkgs, lib, ... }:
    let
      cfg = config.custom.services.zed;
      inherit (lib) mkOption;
      inherit (lib.types) str;
    in
    {
      options.custom.services.zed = {
        fromEmail = mkOption {
          type = str;
          description = "Sender email for zed notifications";
          default = "argon@nitron.app";
        };
        toEmail = mkOption {
          type = str;
          description = "Destination email for zed notifications";
          default = "";
        };
        smtpServer = mkOption {
          type = str;
          description = "Server host for smtp server";
          default = "localhost";
        };
      };
      config = {
        services.zfs = {
          autoScrub.enable = true;
          # Zed to send scrub/alert emails to healthchecks email via msmtp
          zed = {
            enableMail = true;
            settings = {
              ZED_DEBUG_LOG = "/tmp/zed.debug.log";
              ZED_EMAIL_ADDR = [ cfg.toEmail ];
              ZED_EMAIL_PROG = "${pkgs.msmtp}/bin/msmtp";
              ZED_NOTIFY_DATA = true;
              ZED_NOTIFY_VERBOSE = true;
            };
          };
        };
        # SMTP client to send to SMTP server hosted by healthchecks container
        programs.msmtp = {
          enable = true;
          accounts = {
            default = {
              auth = false;
              host = cfg.smtpServer;
              port = 2525;
              from = cfg.fromEmail;
              user = cfg.fromEmail;
            };
          };
        };
      };
    };
}
