{ self, ... }:
{
  # Initialize the foot wrapper
  flake.wrappers.foot =
    { wlib, pkgs, ... }:
    {
      imports = [ wlib.wrapperModules.foot ];
      package = pkgs.foot;
    };

  flake.modules.nixos.foot =
    { lib, config, pkgs, ... }:
    let
      footWrapped = self.wrappers.foot.apply {
        inherit pkgs;
        inherit (config.custom.programs.foot) settings;
      };
      
      inherit (lib)
        mkOption
        ;
      inherit (lib.types)
        attrsOf
        attrs
        ;
    in
    {
      # Expose settings option for other modules to pass extra configuration
      options.custom.programs.foot = {
        settings = mkOption {
          type = attrsOf attrs; # Forces deep recursive merging of attribute sets
          description = "Settings to pass to foot config";
          default = { };
        };
      };

      config = {
        programs.foot = {
          enable = true;
          package = footWrapped.wrapper; # From wrapper above
        };

        # Will pull default font from fontconfig
        custom.programs.foot.settings = {
          main.font = "${lib.head config.fonts.fontconfig.defaultFonts.monospace}:size=11";
          colors.alpha = "0.9"; # transparency for blur
        };

        # Set 256color on remote ssh hosts
        programs.ssh.extraConfig = ''
          Host *
            SetEnv TERM=xterm-256color
        '';
      };
    };
}
