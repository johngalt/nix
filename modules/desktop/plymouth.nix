{ ... }:
{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      boot = {
        plymouth = {
          enable = true;
          theme = "hexa_retro";
          themePackages = with pkgs; [
            (adi1090x-plymouth-themes.override {
              selected_themes = [ "hexa_retro" ];
            })
          ];
        };

        # Enable "Silent boot"
        consoleLogLevel = 3;
        initrd.verbose = false;
        kernelParams = [
          "quiet"
          "udev.log_level=3"
          "systemd.show_status=auto"
        ];
        # Hide the OS choice for bootloaders.
        # It's still possible to open the bootloader list by pressing any key
        # It will just not appear on screen unless a key is pressed
        loader.timeout = 0;

      };
    };
}
