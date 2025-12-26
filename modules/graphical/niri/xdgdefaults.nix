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

  # MIME definitions for less repitition
  imageformats = lib.genAttrs [
    "image/tiff"
    "image/tiff-fx"
    "image/png"
    "image/x-png"
    "image/jpeg"
    "image/jpg"
    "image/pjpeg"
    "image/svg+xml"
    "image/gif"
    "image/bmp"
    "image/x-bmp"
    "image/heif"
    "image/avif"
    "image/jxl"
    "image/webp"
    "image/qoi"
  ] (format: imageviewer);

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
    mkEnableOption
    mkIf
    ;
in 
{
  options.custom.graphical = {
    enableDefaultApps = mkEnableOption "Enable default applications via XDG";
  };
  
  config = mkIf cfg.enableDefaultApps {
    xdg.mime.defaultApplications = lib.mkMerge [
      {
        # File browser
        "inode/directory" = filebrowser;
        # Other types
        "application/pdf" = "org.gnome.Papers.desktop";
      } 
      webformats
      imageformats
    ];
    
    # Installing additional portals (gnome included with niri-flake)
    xdg.portal = {
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      # xdgOpenUsePortal = true;
      # Overriding some portal defaults from niri-flake
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
