{ inputs, self, ... }:
{
  flake.modules.nixos.helix =
    { pkgs, ... }:
    let
      # Wrapper module needs to be passed pkgs first via `.apply`
      helixWrapped = self.wrappers.helix.apply { inherit pkgs; };
    in
    {
      environment.systemPackages = [
        helixWrapped.wrapper # Wrapped package
      ];

      # Go ahead and set it as default
      environment.variables = {
        EDITOR = "hx";
        VISUAL = "hx";
      };
    };

  # Initialize helix wrapper with some default configuration
  # Accessed by calling this wrapper with `.apply` 
  flake.wrappers.helix =
    { lib, wlib, pkgs, ... }:
    let
      # Going to override a builtin theme to allow for transparent background
      themes = {
        gruvbox-transparent = ''
          inherits = "gruvbox_material_dark_medium"
          "ui.background" = { }
        '';
      };
    in
    {
      imports = [ wlib.wrapperModules.helix ];

      # Using helix package from flake inputs (newer than nixpkgs)
      package = inputs.helix.packages.${pkgs.stdenv.hostPlatform.system}.default;

      # Set theme/settings here
      inherit themes;
      settings = {
        theme = "gruvbox-transparent";
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
}
