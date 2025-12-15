{
  lib,
  config,
  ...
}:
let
  cfg = config.custom.system.ssh;
  inherit (lib)
    mkEnableOption
    mkIf
    ;
in
{
  options.custom.system.ssh = {
    enable = mkEnableOption "Enable OpenSSH";
  };

  config = mkIf cfg.enable {
    services = {
      openssh = {
        enable = true;
        settings = {
          UsePAM = false;
          PermitRootLogin = "no";
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
        };
      };
    };
  };
}
