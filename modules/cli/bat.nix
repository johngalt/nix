{ inputs, ... }:
{
  flake.modules.nixos.bat =
    { pkgs, ... }:
    let
      theme = "gruvbox-dark";

      # Will use simple wrapper since there is no wrapper-module for bat
      batWrapped = inputs.wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.bat;
        flags = {
          "--theme" = theme;
          "--style" = "grid";
          "--italic-text" = "always";
        };
      };
    in
    {
      # Using module option to set package instead of environment.systemPackages
      # This way I can reference this wrapped package in other modules if needed
      programs.bat = {
        enable = true;
        package = batWrapped;
      };

      # Set alias to replace cat
      environment.shellAliases = {
        cat = "bat";
      };
    };
}
