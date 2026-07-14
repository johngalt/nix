# This creates the patched nixpkgs that gets passed to nixosConfigurations via withSystem
{ inputs, ... }:
{
  perSystem =
    { system, ... }:
    let
      nixpkgs-patched = inputs.nixpkgs-patcher.lib.patchNixpkgs {
        inherit system inputs;
        inherit (inputs) nixpkgs;
      };
    in
    {
      _module.args.pkgs = import nixpkgs-patched {
        inherit system;
        config = {
          allowUnfree = true;
          # TODO: remove once ZFS is updated
          problems.handlers.zfs.broken = "warn";
        };
      };
    };
}
