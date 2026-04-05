{ ... }:
{
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time = {
    timeZone = "America/Chicago";
    hardwareClockInLocalTime = true;
  };
}
