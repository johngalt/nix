{ ... }:
{
  flake.modules.nixos.desktop =
    { pkgs, lib, ... }:
    let
      fileBrowser = "org.gnome.Nautilus.desktop";
      webBrowser = "firefox.desktop";
      imageViewer = "imv.desktop";
      pdfViewer = "org.gnome.Papers.desktop";

      # Create a list of mime types to be handled by web browser with XDG
      webFormats = lib.genAttrs [
        "application/rdf+xml"
        "application/rss+xml"
        "application/xhtml+xml"
        "application/xhtml_xml"
        "application/xml"
        "text/html"
        "text/xml"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
        "x-scheme-handler/webcal"
        "x-scheme-handler/mailto"
        "x-scheme-handler/about"
        "x-scheme-handler/unknown"
      ]
        (format: webBrowser);

    in
    {
      # Audio settings
      services.pipewire = {
        enable = true;
        pulse.enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        wireplumber.enable = true;
      };
      # Needed for pulse and pipewire
      security.rtkit.enable = true;

      # Font packages and fontconfig settings
      fonts = {
        enableDefaultPackages = true;
        packages = with pkgs; [
          corefonts
          noto-fonts
          cascadia-code
          noto-fonts-color-emoji
          nerd-fonts.jetbrains-mono
        ];
        fontconfig.useEmbeddedBitmaps = true;
        fontconfig.defaultFonts = {
          serif = [ "Noto Serif" ];
          sansSerif = [ "Noto Sans" ];
          monospace = [ "JetBrainsMono NF" ];
          emoji = [ "Noto Color Emoji" ];
        };
      };

      # XDG portal stuff
      xdg.mime.defaultApplications = {
        "images/*" = imageViewer;
        "inode/directory" = fileBrowser;
        "application/pdf" = pdfViewer;
      } // webFormats;
      xdg.portal = {
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
          xdg-desktop-portal-gnome
        ];
        config = {
          common = {
            default = [ "gtk" "gnome" ];
            "org.freedesktop.impl.portal.Access" = [ "gtk" ];
            "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
            "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
            "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
            "org.freedesktop.impl.portal.AppChooser" = [ "gtk" ];
          };
        };
      };
    };
}
