{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.custom.programs.zen;
  system = "x86_64-linux";

  customPolicies = {
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
    NoDefaultBookmarks = true;
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

  zen-unwrapped = inputs.zen-browser.packages."${system}".beta-unwrapped.override {
    policies = customPolicies;
  };
  zen-wrapped =
    (pkgs.wrapFirefox zen-unwrapped {
      icon = "zen-browser";
    }).override
      {
        nativeMessagingHosts = [ pkgs.pywalfox-native ];
      };

  inherit (lib)
    mkEnableOption
    mkIf
    ;

in
{
  options.custom.programs.zen = {
    enable = mkEnableOption "Enable Zen browser";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      zen-wrapped
    ];
  };
}
