{
  config,
  lib,
  pkgs,
  ...
}:
let 
  cfg = config.custom.programs.yazi;

  inherit (lib)
    mkEnableOption
    mkIf
    ;
in 
{
  options.custom.programs.yazi = {
    enable = mkEnableOption "Enable yazi file manager";
  };

  config = mkIf cfg.enable {
    # Some system dependencies for yazi plugins
    environment.systemPackages = with pkgs; [
      ouch
      wl-clipboard
      ueberzugpp
    ];

    # Installs yazi and plugins system-wide via nixpkgs module
    programs = {
      yazi = {
        enable = true;
        plugins = {
          inherit (pkgs.yaziPlugins) 
            git
            wl-clipboard
            full-border
            ouch
            ;
        };
        initLua = pkgs.writeTextFile {
          name = "yazi-init.lua";
          text = ''
            require("full-border"):setup {
              -- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
              type = ui.Border.ROUNDED,
            }
            require("git"):setup()
          '';
        };
        settings.yazi = {
          plugin.prepend_fetchers = [
            {
              id = "git";
              name = "*";
              run = "git";
            }
            {
              id = "git";
              name = "*/";
              run = "git";
            }
          ];
          plugin.prepend_previewers = [
            {
              mime = "application/{*zip,tar,bzip2,7z*,rar,xz,zstd,java-archive}";
              run = "ouch";
            }
          ];
        };
        settings.keymap = {
          mgr.prepend_keymap = [
            {
              on = "C";
              run = "plugin ouch";
              desc = "Compress with ouch";
            }
            {
              on = "<C-y>";
              run = "plugin wl-clipboard";
              desc = "Copy file contents to wl-clipboard";
            }
          ];
        };
      };
    };
  };
}
