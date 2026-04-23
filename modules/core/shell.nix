{ ... }:
{
  flake.modules.nixos.core =
    { pkgs, ... }:
    {
      programs = {
        # Fuzzy finder
        fzf = {
          keybindings = true;
          fuzzyCompletion = true;
        };
        # CD history
        zoxide.enable = true;
        # Fish shell, set as default user shell
        fish = {
          enable = true;
        };
      };

      environment.systemPackages = with pkgs.fishPlugins; [
        fzf-fish
        sponge
      ];

      # Disable man cache generation because it prolongs build times
      documentation.man.cache.enable = false;

      # Disable command-not-found
      programs.command-not-found.enable = false;

      # Starship prompt
      programs.starship = {
        enable = true;
        settings = {
          format = "$username$hostname:$directory$git_branch$nix_shell$character";
          status = {
            disabled = false;
            symbol = "✘";
            style = "fg:red bg:transparent";
            format = "[ $status$symbol]($style)";
          };
          username = {
            disabled = false;
            style_user = "white";
            style_root = "red";
            format = "[$user]($style)";
            show_always = true;
          };
          hostname = {
            ssh_only = false;
            format = "@[$ssh_symbol](bold white)$hostname";
            ssh_symbol = "\\( 🌐\\)";
            disabled = false;
          };
          directory = {
            format = "[$path]($style) ";
            style = "";
            home_symbol = "~";
            truncation_symbol = "…/";
            truncate_to_repo = false;
            read_only = "";
          };
          nix_shell = {
            disabled = false;
            heuristic = true;
            format = "[❄️ \\(Nix Shell\\)](bold white) ";
          };
          git_branch = {
            format = "[| $symbol$branch]($style) ";
            symbol = "  ";
            style = "fg:green bg:transparent";
          };
        };
      };
    };

  # Since the shell is part of my core module, I won't put relative impermanence stuff above
  # I'll put persist files/folders in the impermanence module below so they will only be set if impermanence is enabled
  # If I put this stuff in the nixos.core module, then I'll get errors for hosts without impermanence options
  #  since the option definitions were never set (because the impermanence module wasn't loaded..)
  flake.modules.nixos.impermanence = {
    custom.system.impermanence = {
      persistHome.directories = [
        ".cache/fish"
        ".config/fish"
        ".local/share/fish"
        ".local/share/zoxide"
      ];
    };
  };
}
