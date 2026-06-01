{ ... }:
{
  flake.modules.nixos.core =
    { pkgs, ... }:
    {
      nix = {
        # Set lix as nix package
        package = pkgs.lixPackageSets.latest.lix;
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

          # Extra substituters to use
          substituters = [
            "https://niri.cachix.org"
            "https://noctalia.cachix.org"
            "https://helix.cachix.org"
          ];
          trusted-substituters = [
            "https://niri.cachix.org"
            "https://noctalia.cachix.org"
            "https://helix.cachix.org"
          ];
          trusted-public-keys = [
            "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
            "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
            "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
          ];
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
