{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.graphical;

  # Common applications
  webbrowser = "firefox.desktop";
  filebrowser = "org.gnome.Nautilus.desktop";
  imageviewer = "imv.desktop";

  webformats = lib.genAttrs [
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
  ] (format: webbrowser);

  inherit (lib)
    mkIf
    ;
in
{
  config = mkIf cfg.enable {
    # Set default applications per mime type via XDG
    xdg.mime.defaultApplications = lib.mkMerge [
      {
        # Images
        "image/*" = imageviewer;
        # File browser
        "inode/directory" = filebrowser;
        # Other types
        "application/pdf" = "org.gnome.Papers.desktop";
      }
      webformats
    ];

    # Set xdg portal preferences
    xdg.portal = {
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ];
      # Overriding some portal defaults from niri-flake
      config = {
        common = {
          default = [
            "gtk"
            "gnome"
          ];
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
