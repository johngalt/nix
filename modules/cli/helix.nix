{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  cfg = config.custom.cli.helix;

  # Will install helix from flake rather than nixpkgs
  helixPackage = inputs.helix.packages.${pkgs.stdenv.hostPlatform.system}.default;
  helixTheme = "gruvbox-material";

  inherit (lib)
    mkEnableOption
    mkIf
    ;
in
{
  options.custom.cli.helix = {
    enable = mkEnableOption "Enable helix configuration";
  };

  config = mkIf cfg.enable {
    # Use cachix for binaries to avoid compiling
    nix.settings = {
      extra-substituters = [ "https://helix.cachix.org" ];
      extra-trusted-public-keys = [ "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs=" ];
    };

    # Install helix package from flake rather than nixpkgs
    environment.systemPackages = [
      helixPackage
    ];
    # Set helix as default editor in environment
    environment.variables = {
      EDITOR = "hx";
    };

    # Customize helix at the user-level
    custom.hjem.cfg = {
      rum.programs.helix = {
        enable = true;
        # Using helix package from flake rather than nixpkgs
        package = helixPackage;

        # TODO: Tweak settings
        settings = {
          editor = {
            color-modes = true;
            line-number = "relative";
            end-of-line-diagnostics = "hint";
            rainbow-brackets = true;
            inline-diagnostics = {
              cursor-line = "warning";
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
          theme = helixTheme;
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
              formatter = {
                command = "goimports";
              };
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
              file-types = [
                "yaml"
                "yml"
              ];
              language-servers = [ "yaml" ];
            }
          ];
          language-server = {
            gopls = {
              command = "${lib.getExe pkgs.gopls}";
              args = [
                "-logfile=/tmp/gopls.log"
                "serve"
              ];
              config = {
                "ui.diagnostic.staticcheck" = true;
              };
            };
            yaml = {
              command = "${lib.getExe pkgs.yaml-language-server}";
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
