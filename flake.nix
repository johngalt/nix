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

    # Preserve state with tmpfs root
    preservation.url = "github:nix-community/preservation";

    # Sops for secrets
    sops-nix.url = "github:Mic92/sops-nix";

    # Hjem for some home file linkers
    hjem.url = "github:feel-co/hjem";

    # tuigreet
    tuigreet.url = "github:NotAShelf/tuigreet";
    tuigreet.inputs.nixpkgs.follows = "nixpkgs";
    
    # Niri window manager
    niri.url = "github:sodiboo/niri-flake";

    # Quickshell framework -- not using currently as 0.3 is on nixpkgs
    # quickshell.url = "git+https://git.outfoxxed.me/quickshell/quickshell";
    # quickshell.inputs.nixpkgs.follows = "nixpkgs";

    # Dank Material Shell
    dankMaterialShell.url = "github:AvengeMedia/DankMaterialShell";
    dankMaterialShell.inputs.nixpkgs.follows = "nixpkgs";
    # DMS Plugins
    dms-plugin-registry.url = "github:AvengeMedia/dms-plugin-registry";
    dms-plugin-registry.inputs.nixpkgs.follows = "nixpkgs";

    # Noctalia
    noctalia.url = "github:noctalia-dev/noctalia-shell/v5";

    # Helix modal editor
    helix.url = "github:helix-editor/helix";
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
