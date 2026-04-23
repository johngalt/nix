# Creates a systemd healthchecks service to ping an endpoint for monitoring
# Can easily add healthchecks to existing systemd services by adding something like:
# let
#   checkId = "<ID>>";
# in
# {
#   onFailure = [ "ping-healthchecks@${checkId}:failure.service" ];
#   onSuccess = [ "ping-healthchecks@${checkId}:success.service" ];
#   wants = [ "ping-healthchecks@${checkId}:start.service" ];
# };

{ ... }:
{

  flake.modules.nixos.healthchecks =
    { lib, pkgs, private, ... }:
    let
      healthcheckUrl = "https://healthchecks.${private.domain}";

      pingScript = pkgs.writeShellApplication {
        name = "ping-hc";
        runtimeInputs = [ pkgs.curl ];
        text = ''
          # Source: https://passbe.com/2022/healthchecks-io-systemd-checks/
          # Parse the template variable into actions
          IFS=:
          read -r UUID ACTION <<< "$1"

          # Remove "@localhost" from the UUID
          UUID="''${UUID%%@localhost}"

          if [ "$ACTION" = "start" ]; then
            LOGS=""
            EXIT_CODE="start"
          else
            # Get logs of last invocation
            LAST_TIMESTAMP=$(systemctl show --property InactiveExitTimestamp --value "$MONITOR_UNIT")
            LOGS=$(journalctl --no-pager -u "$MONITOR_UNIT" --since "$LAST_TIMESTAMP" -n 100)

            # This will be 1 in case of error
            # Healthchecks supports "fail" or 1 for this:
            EXIT_CODE=$MONITOR_EXIT_STATUS
          fi

          curl \
            --fail `#fail fast on server errors` \
            --show-error --silent `#show error <=> it fails` \
            --max-time 10 \
            --retry 3 \
            --data-raw "$LOGS" \
            "${healthcheckUrl}/ping/$UUID/$EXIT_CODE"
        '';
      };
    in
    {
      systemd.services = {
        "ping-healthchecks@" = {
          serviceConfig.ExecStart = "${lib.getExe pingScript} %i";
        };
      };
    };
}
