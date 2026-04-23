# This utilizes the wlib.toKdl function
# https://birdeehub.github.io/nix-wrapper-modules/lib/wlib.html#function-library-wlib.toKdl
# KDL gets kind of messy with Nix...
# To have a node with just a name (like keybind acitons), need to use an empty function
{ pkgs, lib, ...}:
{
  "Mod+T".spawn = [ "${lib.getExe pkgs.foot}" ];
  "Mod+Q" = _: { props.repeat = false; content.close-window = _: { }; };
  "Mod+D" = _: { props.repeat = false; content.toggle-overview = _: { }; };

  "Mod+Left".focus-column-or-monitor-left = _: { };
  "Mod+BracketLeft".focus-monitor-left = _: { };
  "Mod+Shift+Left".move-column-left-or-to-monitor-left = _: { };
  "Mod+Shift+BracketLeft".move-column-to-monitor-left = _: { };
  "Mod+Ctrl+Left".consume-or-expel-window-left = _: { };
  "Mod+Up".focus-window-or-workspace-up = _: { };
  "Mod+Shift+Up".move-window-up-or-to-workspace-up = _: { };
  "Mod+Right".focus-column-or-monitor-right = _: { };
  "Mod+BracketRight".focus-monitor-right = _: { };
  "Mod+Shift+Right".move-column-right-or-to-monitor-right = _: { };
  "Mod+Shift+BracketRight".move-column-to-monitor-right = _: { };
  "Mod+Ctrl+Right".consume-or-expel-window-right = _: { };
  "Mod+Down".focus-window-or-workspace-down = _: { };
  "Mod+Shift+Down".move-window-down-or-to-workspace-down = _: { };
  "Mod+Return".maximize-column = _: { };
  "Mod+Shift+Return".set-column-width = "50%";
  "Mod+Ctrl+Return".toggle-window-floating = _: { };
  "Mod+Alt+Return".maximize-window-to-edges = _: { };
  "Mod+Shift+Space".toggle-windowed-fullscreen = _: { };
  "Mod+R".switch-preset-window-height = _: { };
  "Mod+Shift+R".reset-window-height = _: { };
}

