# Global niri binds. Shell specific binds will be in respective module.
{
  "Mod+T" = { spawn = [ "foot" ]; };
  "Mod+Q" = { parameters = { repeat = false; }; action = "close-window"; };
  "Mod+D" = { parameters = { repeat = false; }; action = "toggle-overview"; };

  # Workspace navigation
  "Mod+Left" = { action = "focus-column-or-monitor-left"; };
  "Mod+BracketLeft" = { action = "focus-monitor-left"; };
  "Mod+Shift+Left" = { action = "move-column-left-or-to-monitor-left"; };
  "Mod+Shift+BracketLeft" = { action = "move-column-to-monitor-left"; };
  "Mod+Ctrl+Left" = { action = "consume-or-expel-window-left"; };
  "Mod+Up" = { action = "focus-window-or-workspace-up"; };
  "Mod+Shift+Up" = { action = "move-window-up-or-to-workspace-up"; };
  "Mod+Right" = { action = "focus-column-or-monitor-right"; };
  "Mod+BracketRight" = { action = "focus-monitor-right"; };
  "Mod+Shift+Right" = { action = "move-column-right-or-to-monitor-right"; };
  "Mod+Shift+BracketRight" = { action = "move-column-to-monitor-right"; };
  "Mod+Ctrl+Right" = { action = "consume-or-expel-window-right"; };
  "Mod+Down" = { action = "focus-window-or-workspace-down"; };
  "Mod+Shift+Down" = { action = "move-window-down-or-to-workspace-down"; };
  "Mod+Return" = { action = "maximize-column"; };
  "Mod+Shift+Return" = { action = "set-column-width \"50%\""; };
  "Mod+Ctrl+Return" = { action = "toggle-window-floating"; };
  "Mod+Alt+Return" = { action = "maximize-window-to-edges"; };
  "Mod+Shift+Space" = { action = "toggle-windowed-fullscreen"; };
  "Mod+R" = { action = "switch-preset-window-height"; };
  "Mod+Shift+R" = { action = "reset-window-height"; };
}
