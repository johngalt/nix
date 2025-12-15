{
  config,
  lib,
  ...
}:
let
  cfg = config.custom.desktop;

  # Common applications
  webbrowser = "firefox.desktop";
  filebrowser = "org.kde.dolphin.desktop";
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
  options.custom.desktop = {
    enableDefaultApps = mkEnableOption "Enable default applications via XDG";
  };
  
  config = mkIf cfg.enableDefaultApps {
    xdg.mime.defaultApplications = lib.mkMerge [
      {
        # File browser
        "inode/directory" = filebrowser;
        # Other types
        "application/pdf" = "org.kde.okular.desktop";
      } 
      webformats
      imageformats
    ];
  };
}
