{
  config,
  lib,
  inputs,
  ...
}:
let 
  cfg = config.custom.cli.comma;
  inherit (lib)
    mkEnableOption
    mkIf
    ;
in 
{
  imports = [
    inputs.nix-index-database.nixosModules.default
  ];

  options.custom.cli.comma = {
    enable = mkEnableOption "Enable comma command to run derrivations from nixpkgs";
  };

  config = mkIf cfg.enable {
    # Nix-index + comma
    programs.nix-index-database.comma.enable = true;
    # Disables unknown-command feature (takes too long)
    programs.nix-index.enableFishIntegration = lib.mkForce false;
  };
}
