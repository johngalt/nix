{
  description = "Flake-parts based NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Flake-parts
    flake-parts.url = "github:hercules-ci/flake-parts";
    # Wrapper modules 
    wrappers.url = "github:BirdeeHub/nix-wrapper-modules";
    wrappers.inputs.nixpkgs.follows = "nixpkgs";
    # Private flake for sensitive values
    nix-private.url = "git+ssh://git@github.com/johngalt/private-nix.git?shallow=1";

    # Declarative disk management
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # Wipe root directory with each boot
    impermanence.url = "github:nix-community/impermanence";

    # Sops for secrets
    sops-nix.url = "github:Mic92/sops-nix";

    # Hjem for some home file linkers
    hjem.url = "github:feel-co/hjem";

    # Niri window manager
    niri.url = "github:sodiboo/niri-flake";

    # Quickshell framework -- pinned to avoid breaking shells
    quickshell.url = "git+https://git.outfoxxed.me/quickshell/quickshell";
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
      # Recursive import function to load modules, thanks llakala
      recursivelyImport = import lib/recursivelyImport.nix { inherit lib; };
      # Supported systems
      systems = [ "x86_64-linux" ];
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      inherit systems;
      imports = recursivelyImport [ ./modules ];
    };
}
