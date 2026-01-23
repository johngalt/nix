{
  lib,
  config,
  private,
  pkgs,
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
    environment.systemPackages = with pkgs; [
      wakeonlan
    ];

    # Set default login shell to bash to avoid breaking certain things
    # VSCode remote SSH doesn't work with fish (needs bash)
    # This will launch fish for any interactive shells
    users.users.${private.username}.shell = lib.mkForce pkgs.bash;
    programs.bash.interactiveShellInit = ''
      exec fish
    '';
    
    custom.services = {
      beszel = {
        enable = true;
        environmentFile = config.sops.templates."beszel-agent".path;
      };
      scrutiny = {
        enable = lib.mkDefault false; # Will enable per host (so it isn't enabled on VMs)
        endpoint = "https://scrutiny.${private.domain}";
      };
    };

    # Sops definitions
    # Beszel
    sops.secrets."beszel/sshkey" = { };
    sops.templates."beszel-agent".content = ''
      HUB_URL=https://beszel.${private.domain}
      KEY=${config.sops.placeholder."beszel/sshkey"}
    '';
  };
}
