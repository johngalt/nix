{ self, ... }:
{
  # Desktop profile 
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      imports = with self.modules.nixos; [
        # System modules
        printing
        yubikey
        
        # Desktop environment
        greeter
        niri
        dms
        # noctalia

        # Programs modules
        _1password
        chromium
        firefox
        foot
        syncthing
        vesktop
        yazi
        zed-editor
      ];

      # Other programs installed to system
      environment.systemPackages = with pkgs; [
        wakeonlan
      ];

      # Other programs installed to user profile via hjem
      hj = {
        packages = with pkgs; [
          calibre
          moonlight-qt
          vlc
          obsidian
          rustdesk-flutter
          readest # ebook reader
          imv # image viewer
          papers # Gnome pdf viewer
          zathura # Minimal pdf viewer
          ripdrag # Drag-and-drop from terminal
        ];
      };
    };
}
