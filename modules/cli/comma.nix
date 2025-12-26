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
    {
      # Set this default to false so it can be selectively enabled
      # The imported nixmodule sets it to true for some reason
      config.programs.nix-index.enable = lib.mkOverride 900 false;
    }
  ];

  options.custom.cli.comma = {
    enable = mkEnableOption "Enable comma command to run derrivations from nixpkgs";
  };

  config = mkIf cfg.enable {
    # Nix-index + comma
    programs.nix-index-database.comma.enable = true;
    programs.nix-index.enable = lib.mkForce true;
    # Disables unknown-command feature (takes too long)
    programs.nix-index.enableFishIntegration = lib.mkForce false;
  };
}
