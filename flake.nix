{
  description = "Flake-parts based NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    # Nixpkgs-patcher
    nixpkgs-patcher.url = "github:gepbird/nixpkgs-patcher";
    # Remove once zfs updates to support 7.1 kernel
    nixpkgs-patch-kernel-7-1-zfs = {
      url = "https://gist.githubusercontent.com/johngalt/fbf8f1290e835288e15d0751201f35c1/raw/c8306d01ce8717390a427b639b008eb460441b68/kernel_7_1_zfs.patch";
      flake = false;
    };

    # Claude
    llm-agents.url = "github:numtide/llm-agents.nix";
    
    # Flake-parts
    flake-parts.url = "github:hercules-ci/flake-parts";
    # Wrapper modules 
    wrappers.url = "github:BirdeeHub/nix-wrapper-modules";
    wrappers.inputs.nixpkgs.follows = "nixpkgs";
    # Private flake for sensitive values
    nix-private.url = "git+ssh://git@github.com/johngalt/private-nix.git?shallow=1";

    # Used for some packages (eg helix)
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    # Declarative disk management
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # Preserve state with tmpfs root
    preservation.url = "github:nix-community/preservation";

    # Sops for secrets
    sops-nix.url = "github:Mic92/sops-nix";

    # Hjem for some home file linkers
    hjem.url = "github:feel-co/hjem";

    # Niri window manager
    niri.url = "github:sodiboo/niri-flake";

    # Dank Material Shell
    dankMaterialShell.url = "github:AvengeMedia/DankMaterialShell";
    dankMaterialShell.inputs.nixpkgs.follows = "nixpkgs";
    
    # DMS Plugins
    dms-plugin-registry.url = "github:AvengeMedia/dms-plugin-registry";
    dms-plugin-registry.inputs.nixpkgs.follows = "nixpkgs";

    # Dank calendar
    dankcalendar.url = "github:AvengeMedia/dankcalendar";
    dankcalendar.inputs.nixpkgs.follows = "nixpkgs";

    # Noctalia
    noctalia.url = "github:noctalia-dev/noctalia-shell";

    # Declarative QT styling
    qtengine.url = "github:kossLAN/qtengine";
    qtengine.inputs.nixpkgs.follows = "nixpkgs";
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
