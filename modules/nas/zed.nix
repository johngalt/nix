# Would add module option to this in the future if I needed zed on multiple hosts
{ ... }:
{
  flake.modules.nixos.nas =
    { pkgs, ... }:
    let
      fromEmail = "argon@nitron.app";
      toEmail = "ca2d11ca-98fd-47cf-ace0-0a24184095e0@ping.nitron.app";
    in
    {
      services.zfs = {
        autoScrub.enable = true;
        # Zed to send scrub/alert emails to healthchecks email via msmtp
        zed = {
          enableMail = true;
          settings = {
            ZED_DEBUG_LOG = "/tmp/zed.debug.log";
            ZED_EMAIL_ADDR = [ toEmail ];
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
            host = "localhost";
            port = 2525;
            from = fromEmail;
            user = fromEmail;
          };
        };
      };
    };
}
