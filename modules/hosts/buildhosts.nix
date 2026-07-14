# Borrowed from drupol
# https://github.com/drupol/infra/blob/master/modules/flake-parts/host-machines.nix
{ inputs, lib, config, withSystem, ... }:
let
  # Host configuration "modules" are prefixed with "hosts/"
  prefix = "hosts/";
  # Pull private flake to pass in specialArgs per system
  private = inputs.nix-private.private;
in
{
  flake.nixosConfigurations = lib.pipe config.flake.modules.nixos [
    (lib.filterAttrs (name: _: lib.hasPrefix prefix name)) # Filter out only "hosts/" modules
    # For each "hosts/" module, strip it down to hostname and create nixosSystem which will be passed to nixosConfigurations
    (lib.mapAttrs' (
      name: module:
      let
        # Will pass inputs and private flake to each module
        specialArgs = {
          inherit inputs private;
          # Will pass hostname from module name as argument for config modules to reference
          hostConfig = {
            name = lib.removePrefix prefix name;
            domain = "lan.${private.domain}";
          };
        };
      in
      {
        # Create a nixosSystem for each host that imports the host-specific module
        # Each host will then selectively import modules within their own configuration
        name = lib.removePrefix prefix name;
        # Using withSystem to expose patched nixpkgs to nixosConfigurations
        # https://github.com/gepbird/nixpkgs-patcher/blob/main/doc/flake-parts.md
        value = withSystem "x86_64-linux" (
          { pkgs, system, ... }:
          # Custom lib from nixpkgs-patcher
          inputs.nixpkgs-patcher.lib.nixosSystem {
            inherit specialArgs system;
            nixpkgsPatcher.inputs = inputs;
            modules = [
              # Sets nixpkgs to the patched version provided with `withSystem`
              { nixpkgs.pkgs = pkgs; }              
              module
            ];
          }
        );
      }
    ))
  ];
}
