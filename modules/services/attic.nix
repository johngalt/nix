{ ... }:
{
  flake.modules.nixos.attic =
  { config, ... }:
  {
    sops.secrets."attic/rsaKey" = {};
    sops.templates."atticEnvironment".content = ''
      ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64="${config.sops.placeholder."attic/rsaKey"}"
    '';
  
    services.atticd = {
      enable = true;
      environmentFile = config.sops.templates."atticEnvironment".path;
      settings = {
        listen = "[::]:8085";
        jwt = { };
      };
    };
    networking.firewall.allowedTCPPorts = [ 8085 ];
  };
}
