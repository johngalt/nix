{ ... }:
{
  flake.modules.nixos.core = {
    services.openssh = {
      enable = true;
      # Sensible defaults for SSH
      # No root login, force pubkey authentication
      settings = {
        UsePAM = false;
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };
  };
}
