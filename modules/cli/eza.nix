{ self, ... }:
{
  flake.wrappers.eza =
    { wlib, pkgs, config, ... }:
    let
      # Custom package for the eza-themes repository
      eza-themes = pkgs.callPackage ../../packages/eza-themes {  };
      theme = "gruvbox-dark";
    in
    {
      # Default wrapper module pulls in things like `env` and `flags`
      imports = [ wlib.modules.default ];
      package = pkgs.eza;

      # Pull the theme into the wrapper
      constructFiles."eza-theme.yml" = {
        content = builtins.readFile "${eza-themes}/share/eza-themes/${theme}.yml";
        relPath = "eza/theme.yml";
      };

      # Eza needs me to specify the config directory to set the theme ...
      env = {
        EZA_CONFIG_DIR = dirOf config.constructFiles."eza-theme.yml".path;
      };
      flagSeparator = "=";
      flags = {
        "--icons" = "auto";
        "--hyperlink" = true;
      };
    };
    
  flake.modules.nixos.eza =
    { pkgs, ... }:
    let
      ezaWrapped = self.wrappers.eza.apply { inherit pkgs; };
    in
    {
      environment.systemPackages = [
        ezaWrapped.wrapper # Wrapped package
      ];

      # Eza-specific shell aliases
      environment.shellAliases = {
        ls = "eza";
        ll = "eza -la";
        tree = "eza --tree --git-ignore";
      };
    };
}
