{
  config,
  lib,
  pkgs,
  ...
}:
let 
  cfg = config.custom.system.shell;
  
  # Common shell aliases to apply to all hosts
  commonAliases = {
    # Move this one
    flinks = "find . -links 1 -type f ! -name '*.png' ! -name '*.jpg' ! -name '*sample*' ! -name '*.nfo' ! -name '*.srt'";
  };

  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    ;
  inherit (lib.types)
    attrs
    ;

in 
{
  options.custom.system.shell = {
    enable = mkEnableOption "Enable shell configurations";
    aliases = mkOption {
      type = attrs;
      description = "Extra aliases to apply to shell configuration";
      default = { };
    };
  };

  config = mkIf cfg.enable {
    programs = {
      # Fuzzy finder
      fzf = {
        keybindings = true;
        fuzzyCompletion = true;
      };
      # Zixode for cd history
      zoxide.enable = true;
      # Fish shell
      fish.enable = true;
    };

    # Fish plugins
    environment.systemPackages = with pkgs.fishPlugins; [
      fzf-fish
    ];

    # Merge common aliases and extra aliases from module configuration
    environment.shellAliases = mkMerge [
      commonAliases
      cfg.aliases
    ];

    # Disable man cache generation because it prolongs build times
    documentation.man.generateCaches = lib.mkForce false;

    # Starship prompt
    programs.starship = {
      enable = true;
    };

    # TODO: rewrite starship config into nix format with programs.starship.settings option
    # custom.hjem.cfg = {
    #   files.".config/starship.toml".text = ''
    #     # Two-line prompt
    #     format = """
    #     [](bg:transparent fg:bright-purple)$os[](fg:bright-purple bg:cyan)$directory$git_branch[](fg:cyan bg:transparent)$status
    #     $character
    #     """

    #     [status]
    #     disabled = false
    #     symbol = "✘"
    #     style = "fg:red bg:transparent"
    #     format = "[ $status$symbol]($style)"

    #     [os]
    #     disabled = false
    #     format = "[$symbol ]($style)"
    #     style = "bg:bright-purple fg:black"

    #     [os.symbols]
    #     Alpine = ""
    #     Arch = ""
    #     Debian = ""
    #     EndeavourOS = ""
    #     Fedora = ""
    #     Gentoo = ""
    #     Macos = ""
    #     Manjaro = ""
    #     Mint = ""
    #     NixOS = ""
    #     openSUSE = ""
    #     Pop = ""
    #     Raspbian = ""
    #     Redhat = ""
    #     RedHatEnterprise = ""
    #     RockyLinux = ""
    #     Ubuntu = ""
    #     Void = ""
    #     Linux = ""

    #     [time]
    #     disabled = true
    #     time_format = "%R"
    #     style = "bg:white fg:black"
    #     format = "[ 󱑍 $time ]($style)"

    #     [directory]
    #     format = "[ $path ]($style)"
    #     style = "fg:black bg:cyan"
    #     home_symbol = "~"
    #     truncation_symbol = "…/"
    #     truncate_to_repo = false
    #     read_only = ""

    #     [git_branch]
    #     format = "[| $symbol$branch]($style)"
    #     symbol = "  "
    #     style = "fg:black bg:cyan"
    #   '';
    # };
  };
}
