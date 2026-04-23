{ ... }:
{
  flake.modules.nixos.core = {
    # Miscellaneous options/settings
    time = {
      timeZone = "America/Chicago";
      hardwareClockInLocalTime = true;
    };
  };
}
