{
  lib,
  config,
  private,
  ...
}:
let
  cfg = config.custom.profiles.server;

  inherit (lib)
    mkEnableOption
    mkIf
    ;
in
{
  options.custom.profiles.server = {
    enable = mkEnableOption "Enable general server modules";
  };

  config = mkIf cfg.enable {
    # Sops definitions
    # Beszel
    sops.secrets."beszel/sshkey" = { };
    sops.templates."beszel-agent".content = ''
      HUB_URL=https://beszel.${private.domain}
      KEY=${config.sops.placeholder."beszel/sshkey"}
    '';

    custom.services.beszel = {
      enable = true;
      environmentFile = config.sops.templates."beszel-agent".path;
    };
  };
}
