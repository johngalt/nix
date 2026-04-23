{ ... }:
{
  flake.modules.nixos.printing =
    { pkgs, ... }:
    {
      services = {
        printing.enable = true;
        printing.drivers = [ pkgs.brlaser ];
        avahi = {
          enable = true;
          nssmdns4 = true;
          openFirewall = true;
        };
      };
    };
}
