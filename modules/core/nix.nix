{ ... }:
{
  flake.modules.nixos.core =
    { pkgs, ... }:
    {
      nix = {
        # Disable channels, set nixpkgs to this flake's input nixpkgs
        channel.enable = false;
        nixPath = [ "nixpkgs=${pkgs.path}" ];

        # Garbage collection and store optimization
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

        settings = {
          experimental-features = [ "nix-command" "flakes" ];
          trusted-users = [ "@wheel" ];
          auto-optimise-store = true;
          warn-dirty = false;
        };

        # Sensible defaults
        # From https://jackson.dev/post/nix-reasonable-defaults/
        extraOptions = ''
          connect-timeout = 5
          log-lines = 50
          min-free = 128000000
          max-free = 1000000000
          fallback = true
        '';
      };
      nixpkgs.config.allowUnfree = true;
      system.stateVersion = "24.11";
    };
}
