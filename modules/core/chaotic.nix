{ inputs, ... }:
{
  flake.modules.nixos.core = {
    imports = [
      inputs.chaotic.nixosModules.default
    ];
  };
} 
