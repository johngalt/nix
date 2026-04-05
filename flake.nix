{
  description = "Home NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Private flake for sensitive values
    nix-private.url = "git+ssh://git@github.com/johngalt/private-nix.git?shallow=1";

    # Declarative disk management
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # Wipe root directory with each boot
    impermanence.url = "github:nix-community/impermanence";

    # Sops for secrets
    sops-nix.url = "github:Mic92/sops-nix";

    # Hjem and Hjem-rum for home file management
    hjem.url = "github:feel-co/hjem";
    hjem-rum.url = "github:snugnug/hjem-rum";
    hjem-rum.inputs.nixpkgs.follows = "nixpkgs";
    hjem-rum.inputs.hjem.follows = "hjem";

    # Niri window manager
    niri.url = "github:sodiboo/niri-flake";

    # Quickshell framework -- pinned to avoid breaking shells
    quickshell.url = "git+https://git.outfoxxed.me/quickshell/quickshell?rev=41828c4180fb921df7992a5405f5ff05d2ac2fff";
    quickshell.inputs.nixpkgs.follows = "nixpkgs";

    # Dank Material Shell
    dankMaterialShell.url = "github:AvengeMedia/DankMaterialShell";
    dankMaterialShell.inputs.nixpkgs.follows = "nixpkgs";
    # DMS Plugins
    dms-plugin-registry.url = "github:AvengeMedia/dms-plugin-registry";
    dms-plugin-registry.inputs.nixpkgs.follows = "nixpkgs";

    # Helix modal editor
    helix.url = "github:helix-editor/helix";
    helix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { ... }@inputs:
    let
      lib = inputs.nixpkgs.lib;
      private = inputs.nix-private.private;

      # Function from llakala to recursively import nix modules
      recursivelyImport = import lib/recursivelyImport.nix { inherit lib; };

      # List of hosts and builder function to build nixos configurations for
      hosts = [
        "atlas"
        "argon"
        "incus"
        "hydra"
        "dns01"
        "bootstrap"
        "cesium"
      ];
      mkSystem =
        host:
        lib.nixosSystem {
          specialArgs = { inherit inputs private; };
          modules =
            recursivelyImport [
              ./hosts/${host}
              ./modules
            ]
            ++ [ (import ./overlays) ]; # TODO: Move overlays to just custom package definitions
        };
    in
    {
      nixosConfigurations = lib.genAttrs hosts mkSystem;
    };
}
