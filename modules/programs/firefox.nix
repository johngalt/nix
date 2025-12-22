{
  config,
  lib,
  ...
}:
let
  cfg = config.custom.programs.firefox;

  inherit (lib)
    mkEnableOption
    mkIf
    ;
in
{
  options.custom.programs.firefox = {
    enable = mkEnableOption "Enable Firefox";
  };

  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      # Custom policies to disable things in firefox declaratively
      policies = {
        AutofillCreditCardEnabled = false;
        AutofillAddressEnabled = false;
        DisableFirefoxStudies = true;
        DisableFeedbackCommands = true;
        DisableTelemetry = true;
        DisableMasterPasswordCreation = true;
        DisplayBookmarksToolbar = "always";
        DontCheckDefaultBrowser = true;
        OfferToSaveLogins = false;
        PasswordManagerEnabled = false;
        PrimaryPassword = false;
        SkipTermsOfUse = true;
        VisualSearchEnabled = false;
        DisablePocket = true;
        WindowsSSO = false;
        EnableTrackingProtection = {
          Cryptomining = true;
          Fingerprinting = true;
          EmailTracking = true;
        };

        FirefoxHome = {
          Search = false;
          TopSites = false;
          SponsoredTopSites = false;
          Highlights = false;
          Pocket = false;
          Stories = false;
          SponsoredPocket = false;
          SponsoredStories = false;
          Snippets = false;
          Locked = true;
        };

        FirefoxSuggest = {
          WebSuggestions = false;
          SponsoredSuggestions = false;
          ImproveSuggest = false;
          Locked = true;
        };

        GenerativeAI = {
          Enabled = false;
          Chatbot = false;
          LinkPreviews = false;
          TabGroups = false;
          Locked = true;
        };

        Homepage = {
          StartPage = "none";
          Locked = true;
        };
        UserMessaging = {
          WhatsNew = false;
          ExtensionRecommendations = false;
          FeatureRecommendations = false;
          UrlbarInterventions = false;
          SkipOnBoarding = false;
          MoreFromMozilla = false;
          FirefoxLabs = false;
        };
      };
    };
  };
}
