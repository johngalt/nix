{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.custom.programs.chromium;
  inherit (lib)
    mkEnableOption
    mkIf
    ;
in
{
  options.custom.programs.chromium = {
    enable = mkEnableOption "Enable chromium browser";
  };

  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      chromium
    ];

    programs.chromium = {
      enable = true;
      extensions = [
        "imfcckkmcklambpijbgcebggegggkgla" # Monarch Retail Sync
        "bjfcejklblacnehdgcjjlnejbdjlnohn" # Monarch Money Tweaks
        "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
      ];
      extraOpts = {
        "PasswordManagerEnabled" = false;
        "AutofillCreditCardEnabled" = false;
      };
      # enablePlasmaBrowserIntegration = true;
    };
  };
}
