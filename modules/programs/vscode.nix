{
  config,
  lib,
  pkgs,
  ...
}:
let 
  cfg = config.custom.programs.vscode;
  inherit (lib)
    mkEnableOption
    mkIf
    ;
in 
{
  options.custom.programs.vscode = {
    enable = mkEnableOption "Enable VSCode";
  };

  config = mkIf cfg.enable {
    # Packages to support LSP with nix
    environment.systemPackages = with pkgs; [
      nixd
    ];

    # TODO: declaritive vscode extensions (esp nix ide)
    custom.hjem.cfg = {
      rum.programs.vscode = {
        enable = true;
      };
    };
  };
}
