{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let 
  cfg = config.custom.cli.helix;
  
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    ;
  inherit (lib.types)
    str
    ;

in 
{
  options.custom.cli.helix = {
    enable = mkEnableOption "Enable helix configuration";
    theme = mkOption {
      type = str;
      description = "Helix theme to set";
      default = "";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      inputs.helix.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
    
    custom.hjem.cfg = {
      rum.programs.helix = {
        enable = true;
        package = inputs.helix.packages.${pkgs.stdenv.hostPlatform.system}.default;
        
        settings = {
          editor = {
            color-modes = true;
            line-number = "relative";
            end-of-line-diagnostics = "hint";
            rainbow-brackets = true;
            inline-diagnostics = {
              cursor-line = "warning";
              other-lines = "warning";
            };
            statusline = {
              mode = {
                normal = "NORMAL";
                insert = "INSERT";
                select = "SELECT";
              };
            };
            lsp = {
              display-messages = true;
              display-inlay-hints = true;
            };
            cursor-shape = {
              insert = "bar";
              normal = "block";
              select = "underline";
            };
            indent-guides.render = true;
          };
          theme = cfg.theme;
          # Keybinds
          keys.normal = {
            X = "select_line_above";
          };
        };
        languages = {
          language = [
            {
              name = "go";
              auto-format = true;
              formatter = { command = "goimports"; };
            }
            {
              name = "nix";
              auto-format = false;
              formatter = {
                command = "${lib.getExe pkgs.nixpkgs-fmt}";
              };
              file-types = [ "nix" ];
              language-servers = [ "nixd" ];
            }
            {
              name = "yaml";
              auto-format = true;
              file-types = [ "yaml" "yml" ];
              language-servers = [ "yaml" ];
            }
          ];
          language-server = {
            gopls = {
              command = "${lib.getExe pkgs.gopls}";
              args = [ "-logfile=/tmp/gopls.log" "serve" ];
              config = { "ui.diagnostic.staticcheck" = true; };
            };
            yaml = {
              command = "${pkgs.nodePackages.yaml-language-server}/bin/yaml-language-server";
              args = [ "--stdio" ];
            };
            nixd = {
              command = "${lib.getExe pkgs.nixd}";
              args = [ ];
            };
          };
        };
      };
    };
  };
}
