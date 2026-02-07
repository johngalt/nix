{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.services.healthchecks;
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    ;
  inherit (lib.types)
    str
    ;
in
{
  options.custom.services.healthchecks = {
    enable = mkEnableOption "Enable healthchecks systemd service for pinging a healthchecks instance";
    targetUrl = mkOption {
      type = str;
      description = "URL of healthchecks instance to use";
      example = ''
        https://healthchecks.DOMAIN.TLD
      '';
    };
  };

  # Add something like this to systemd services you want to monitor with health checks:
  # let
  #   checkId = "<ID>>";
  # in
  # {
  #   onFailure = [ "ping-healthchecks@${checkId}:failure.service" ];
  #   onSuccess = [ "ping-healthchecks@${checkId}:success.service" ];
  #   wants = [ "ping-healthchecks@${checkId}:start.service" ];
  # };

  config = mkIf cfg.enable {
    systemd.services = {
      "ping-healthchecks@" = {
        serviceConfig.ExecStart =
          let
            ping-hc = pkgs.writeShellApplication {
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
                  "${cfg.targetUrl}/ping/$UUID/$EXIT_CODE"
              '';
            };
          in
          "${lib.getExe ping-hc} %i";
      };
    };
  };
}
