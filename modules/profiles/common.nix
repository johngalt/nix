{
  lib,
  config,
  private,
  pkgs,
  ...
}:
let
  cfg = config.custom.profiles.common;

  # Helper functions for adding extra groups
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
  extraGroups = [
    "wheel"
  ]
  ++ ifTheyExist [
    "networkmanager"
    "docker"
    "video"
    "render"
  ];

  inherit (lib)
    mkOption
    mkIf
    ;
  inherit (lib.types)
    bool
    ;
in
{
  options.custom.profiles.common = {
    enable = mkOption {
      type = bool;
      description = "Enable common modules";
      default = true;
    };
  };
  config = mkIf cfg.enable {

    # Custom module settings
    custom = {
      system = {
        ssh.enable = true;
        zsh = {
          enable = true;
          aliases = {
            neofetch = "fastfetch";
            ls = "eza --icons=always --width=100";
            ll = "eza -l -a --icons=auto";
            tree = "ls --tree --git-ignore";
            cat = "bat";
            flinks = "find . -links 1 -type f ! -name '*.png' ! -name '*.jpg' ! -name '*sample*' ! -name '*.nfo' ! -name '*.srt'";
          };
        };
      };
      cli = {
        nh = {
          enable = true;
          flake = "/home/${private.username}/git/nixos";
        };
        bat = {
          enable = true;
          theme = "gruvbox-dark";
        };
      };
    };

    # Common system packages to install
    environment.systemPackages = with pkgs; [
      git
      nano
      wget
      btop
      ncdu
      bat
      eza
      fastfetch
      sops
      age
      nixfmt-rfc-style
      systemctl-tui
      wakeonlan
      duf
    ];

    # Nixos modules
    programs = {
      fzf = {
        keybindings = true;
        fuzzyCompletion = true;
      };
      zoxide.enable = true;
    };

    # User settings
    sops.secrets."userpass/${private.username}".neededForUsers = true;

    users.mutableUsers = false;
    users.users = {
      ${private.username} = {
        isNormalUser = true;
        inherit extraGroups;
        shell = pkgs.zsh;
        hashedPasswordFile = config.sops.secrets."userpass/${private.username}".path;
        openssh.authorizedKeys.keys = [
          private.key
        ];
      };
    };
  };
}
