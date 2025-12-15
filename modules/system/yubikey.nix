{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.custom.system.yubikey;
  inherit (lib)
    mkEnableOption
    mkIf
    ;
in
{
  options.custom.system.yubikey = {
    enable = mkEnableOption "Enable Yubikey support";
  };

  config = mkIf cfg.enable {
    services = {
      pcscd.enable = true;
      udev.packages = [ pkgs.yubikey-personalization ];
    };

    environment.systemPackages = with pkgs; [
      yubioath-flutter
    ];

  };
}
