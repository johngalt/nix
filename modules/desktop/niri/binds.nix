# Global niri binds. Shell specific binds will be in respective module.
{
  "Mod+T" = { spawn = [ "alacritty" ]; };
  "Mod+Q" = { parameters = { repeat = false; }; action = "close-window"; };

  # Workspace navigation
  "Mod+Left" = { action = "focus-column-left"; };
  "Mod+Shift+Left" = { action = "move-column-left"; };
  "Mod+Ctrl+Left" = { action = "consume-or-expel-window-left"; };
  "Mod+Up" = { action = "focus-workspace-up"; };
  "Mod+Shift+Up" = { action = "move-window-up-or-to-workspace-up"; };
  "Mod+Right" = { action = "focus-column-right"; };
  "Mod+Shift+Right" = { action = "move-column-right"; };
  "Mod+Ctrl+Right" = { action = "consume-or-expel-window-right"; };
  "Mod+Down" = { action = "focus-workspace-down"; };
  "Mod+Shift+Down" = { action = "move-window-down-or-to-workspace-down"; };
  "Mod+Return" = { action = "maximize-column"; };
  "Mod+Shift+Return" = { action = "set-column-width \"50%\""; };
  "Mod+Shift+Space" = { action = "toggle-windowed-fullscreen"; };
}
