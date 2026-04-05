{ ... }:
{
  nix = {
    settings = {
      # Enable flakes
      experimental-features = "nix-command flakes";
      trusted-users = [ "@wheel" ];
    };

    # Disable nix-channel
    channel.enable = false;

    # Automatic garbage collection and optimisation
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 20d";
      persistent = true;
    };
    optimise = {
      automatic = true;
      persistent = true;
    };
  };
  nixpkgs.hostPlatform = "x86_64-linux";
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "24.11";
}
