{
  description = "Home NixOS Configuration";

  inputs = {
    # Private flake
    nix-private.url = "git+ssh://git@github.com/johngalt/private-nix.git?shallow=1";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Disko -- declarative disk management
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Impermanence -- persistent root storage
    impermanence.url = "github:nix-community/impermanence";
    # SOPS -- secrets management
    sops-nix.url = "github:Mic92/sops-nix";
    # Hjem -- home file management
    hjem.url = "github:feel-co/hjem";
    hjem-rum = {
      url = "github:snugnug/hjem-rum";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.hjem.follows = "hjem";
    };
    # Niri
    niri.url = "github:sodiboo/niri-flake";
    niri-session-manager = {
      url = "github:MTeaHead/niri-session-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Quickshell pinned to release
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell?rev=26531fc46ef17e9365b03770edd3fb9206fcb460";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Dank Material Shell
    dgop = {
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dankMaterialShell = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.dgop.follows = "dgop";
    };
    # Noctalia shell
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      # Private attrset to utilize in other configurations
      private = inputs.nix-private.private;

      # List of hosts to build configurations for
      hosts = [
        "atlas"
        "argon"
        "incus"
        "hydra"
        "dns01"
        "bootstrap"
      ];
    in
    {
      # Set default formatter to nixfmt-rfc-style
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;

      # Function to build nixosConfigurations for each host
      nixosConfigurations = lib.genAttrs hosts (
        host:
        lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit
              inputs
              outputs
              private
              ;
          };
          modules = [
            ./hosts/${host} # Host-specific configurations
            ./modules # Custom modules
            (import ./overlays) # Custom overlays
          ];
        }
      );
    };
}
