{ ... }:
{
  flake.modules.nixos.yubikey =
    { pkgs, ... }:
    {
      # Yubikey supporting system services
      services = {
        pcscd.enable = true;
        udev.packages = with pkgs; [ yubikey-personalization ];
      };

      # GUI App for Yubikey
      environment.systemPackages = with pkgs; [ yubioath-flutter ];
    };
}
