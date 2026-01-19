{
  lib,
  config,
  private,
  pkgs,
  ...
}:
let
  cfg = config.custom.profiles.base;

  inherit (lib)
    mkOption
    mkIf
    ;
  inherit (lib.types)
    bool
    ;
in
{
  options.custom.profiles.base = {
    enable = mkOption {
      type = bool;
      description = "Enable base configuration modules";
      default = true;
    };
  };

  config = mkIf cfg.enable {
    # Common system packages to install
    environment.systemPackages = with pkgs; [
      nano
      helix
      wget
      btop
      ncdu
      fastfetch
      nixfmt
      systemctl-tui
      wakeonlan
      duf
      fd
      fq
      duf
      nixpkgs-track
      unzip
    ];

    # Custom module settings
    custom = {
      # Hjem for home file management
      hjem = {
        enable = true;
        user = private.username;
      };
      system = {
        ssh.enable = true;
        shell.enable = true;
      };
      cli = {
        git = {
          enable = true;
          name = private.fullname;
          email = private.email;
        };
        nh = {
          enable = true;
          flake = "/home/${private.username}/git/nixos";
        };
        bat = {
          enable = true;
          theme = "gruvbox-dark";
        };
        eza = {
          enable = true;
          theme = "gruvbox-dark";
        };
      };
    };
  };
}
