{
  description = "Home NixOS Configuration";

  inputs = {
    # Private flake
    nix-private.url = "git+ssh://git@github.com/johngalt/private-nix.git?shallow=1";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Nix-index
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    # Quickshell pinned to release
    quickshell = {
      url = "git+https://git.outfoxxed.me/quickshell/quickshell?rev=41828c4180fb921df7992a5405f5ff05d2ac2fff";
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
    };
    # Testing repo
    # dms-test = {
    #   url = "github:AvengeMedia/DankMaterialShell/doctor";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # Noctalia shell
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Zen browser
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
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
