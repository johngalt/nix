{
  config,
  lib,
  ...
}:
let
  cfg = config.custom.system.zsh;

  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    ;
  inherit (lib.types)
    attrs
    ;

in
{
  options.custom.system.zsh = {
    enable = mkEnableOption "Enable ZSH module";
    aliases = mkOption {
      type = attrs;
      description = "ZSH aliases";
      default = { };
    };
  };

  config = mkIf cfg.enable {
    programs = {
      zsh = {
        enable = true;
        syntaxHighlighting.enable = true;
        autosuggestions.enable = true;
        shellAliases = cfg.aliases;
      };
    };
  };
}
