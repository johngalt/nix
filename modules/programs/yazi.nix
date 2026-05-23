# The nixpkgs yazi module actually ends up creating a nice wrapper for yazi
# No point in me re-inventing the wheel and wrapping it again
{ ... }:
{
  flake.modules.nixos.yazi =
    { pkgs, ... }:
    let
      yazi-gruvbox-material = pkgs.callPackage ../../packages/yazi-gruvbox-material { };
    in
    {
      # Some system dependencies for yazi plugins
      environment.systemPackages = with pkgs; [
        ouch
        wl-clipboard
        ueberzugpp
      ];

      programs = {
        yazi = {
          enable = true;
          plugins = {
            inherit (pkgs.yaziPlugins)
              git
              full-border
              ouch
              smart-enter
              ;
          };
          flavors = {
            gruvbox-material = yazi-gruvbox-material;
          };
          initLua = pkgs.writeTextFile {
            name = "yazi-init.lua";
            # Init git and full-border plugins
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
                run = "shell -- for path in %s; do echo \"file://$path\"; done | wl-copy -t text/uri-list";
                desc = "Copy file contents to wl-clipboard";
              }
              {
                on = "<C-n>";
                run = "shell -- ripdrag --no-click --and-exit --icon-size 64 --all \"$@\"";
                desc = "Open selected files in ripdrag";
              }
              {
                on = "l";
                run = "plugin smart-enter";
                desc = "Enter the child directory, or open the file";
              }
            ];
          };
          settings.theme = {
            flavor = {
              light = "gruvbox-material";
              dark = "gruvbox-material";
            };
          };
        };
        # Fish function for yazi
        fish = {
          interactiveShellInit = ''
            function y
              set tmp (mktemp -t "yazi-cwd.XXXXXX")
              yazi $argv --cwd-file="$tmp"
              if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
                builtin cd -- "$cwd"
              end
              rm -f -- "$tmp"
            end
          '';
        };
      };
    };
}
