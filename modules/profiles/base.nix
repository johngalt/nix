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
    # Base system packages to install
    environment.systemPackages = with pkgs; [
      nano
      wget
      btop
      ncdu
      fastfetch
      nixfmt
      duf
      fd
      fq
      duf
      jq
      dix
      ripgrep
      nixpkgs-track
      unzip
    ];

    # Custom module settings for base profile
    custom = {
      hjem = {
        enable = true;
        user = private.username;
      };
      system = {
        ssh.enable = true;
        shell.enable = true;
      };
      cli = {
        nh = {
          enable = true;
          flake = "/home/${private.username}/git/nixos";
        };
        git.enable = true;
        bat.enable = true;
        eza.enable = true;
        helix.enable = true;
      };
    };
  };
}
