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
        # TODO: https://github.com/gepbird/nixpkgs-patcher/blob/main/doc/configuration.md#reusing-the-patched-nixpkgs
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
            "https://cache.numtide.com"
            "https://devenv.cachix.org"
            "https://cachix.cachix.org"
          ];
          trusted-substituters = [
            "https://niri.cachix.org"
            "https://noctalia.cachix.org"
            "https://helix.cachix.org"
            "https://nyx-cache.chaotic.cx"
            "https://cache.numtide.com"
            "https://devenv.cachix.org"
            "https://cachix.cachix.org"
          ];
          trusted-public-keys = [
            "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
            "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
            "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
            "nyx-cache.chaotic.cx:dJxTrgMC3V3cFfyIiBQDQorG6k1LsqurH/srpMSq7qk="
            "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
            "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
            "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
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
      # nixpkgs.config.allowUnfree = true;
      system.stateVersion = "24.11";
    };
}
