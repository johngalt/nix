{ ... }:
{
  flake.modules.nixos.firefox =
    { pkgs, ... }:
    {
      # Pywalfox for firefox theming
      environment.systemPackages = with pkgs; [
        pywalfox-native
      ];

      programs.firefox = {
        enable = true;
        # Custom policies to disable a bunch of things in firefox
        policies = {
          AutofillCreditCardEnabled = false;
          AutofillAddressEnabled = false;
          DisableFirefoxStudies = true;
          DisableFeedbackCommands = true;
          DisableTelemetry = true;
          DisableMasterPasswordCreation = true;
          DisplayBookmarksToolbar = "always";
          NoDefaultBookmarks = true;
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

          # Automatically install extensions
          ExtensionSettings = {
            # uBlock Origin
            "uBlock0@raymondhill.net" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
              installation_mode = "force_installed";
            };
            # 1Password
            "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
              installation_mode = "force_installed";
            };
            # Imagus
            "{00000f2a-7cde-4f20-83ed-434fcb420d71}" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/imagus/latest.xpi";
              installation_mode = "force_installed";
            };
            # Karakeep
            "addon@karakeep.app" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/karakeep/latest.xpi";
              installation_mode = "force_installed";
            };
            # Monarch Money Tweaks
            "Monarch-Money-Tweaks@paresi.robert" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/monarch-money-tweaks/latest.xpi";
              installation_mode = "force_installed";
            };
            # Pywalfox
            "pywalfox@frewacom.org" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/pywalfox/latest.xpi";
              installation_mode = "force_installed";
            };
            # Reddit Enhancement Suite
            "jid1-xUfzOsOFlzSOXg@jetpack" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/reddit-enhancement-suite/latest.xpi";
              installation_mode = "force_installed";
            };
            # Sponsor Block for YouTube
            "sponsorBlocker@ajay.app" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
              installation_mode = "force_installed";
            };
            # SteamDB
            "firefox-extension@steamdb.info" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/steam-database/latest.xpi";
              installation_mode = "force_installed";
            };
          };
        };
      };
    };
}
