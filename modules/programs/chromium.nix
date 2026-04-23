{ ... }:
{
  flake.modules.nixos.chromium =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        chromium
      ];
      programs.chromium = {
        enable = true;
        extensions = [
          "imfcckkmcklambpijbgcebggegggkgla" # Monarch Retail Sync
          "bjfcejklblacnehdgcjjlnejbdjlnohn" # Monarch Money Tweaks
          "aeblfdkhhhdcdjpifhhbdiojplfjncoa" # 1Password
          "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
        ];
        extraOpts = {
          "PasswordManagerEnabled" = false;
          "AutofillCreditCardEnabled" = false;
          "AutofillAddressEnabled" = false;
          "GenAiDefaultSettings" = 2; # Disables generative AI
        };
      };

      # Set home directories to persist if enabled
      custom.system.impermanence = {
        persistHome.directories = [
          ".config/chromium"
          ".cache/chromium"
        ];
      };
    };
}
