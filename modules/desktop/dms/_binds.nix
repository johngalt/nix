# DMS-specific binds (most using dms ipc)
{ lib, pkgs, ... }:
{
  "Mod+Shift+S" = {
    action = "spawn-sh \"dms screenshot --cursor=off -d ~/Pictures/Screenshots\"";
  };
  "Mod+Ctrl+S" = {
    action = "spawn-sh \"dms screenshot --stdout | ${lib.getExe pkgs.satty} -f - --early-exit --save-after-copy --actions-on-enter save-to-clipboard --output-filename ~/Pictures/Screenshots/satty-$(date '+%Y%m%d-%H:%M:%S').png\"";
  };
  "Mod+Space" = {
    spawn = [ "dms" "ipc" "call" "launcher" "toggle" ];
    parameters = { hotkey-overlay-title = "Launcher"; };
  };
  "Mod+V" = {
    spawn = [ "dms" "ipc" "call" "clipboard" "toggle" ];
    parameters = { hotkey-overlay-title = "Clipboard Manager"; };
  };
  "Mod+N" = {
    spawn = [ "dms" "ipc" "call" "notifications" "toggle" ];
    parameters = { hotkey-overlay-title = "Notification Center"; };
  };
  "Mod+Shift+N" = {
    spawn = [ "dms" "ipc" "call" "notepad" "toggle" ];
    parameters = { hotkey-overlay-title = "Notepad"; };
  };
  "Mod+Alt+L" = {
    spawn = [ "dms" "ipc" "call" "lock" "lock" ];
    parameters = { hotkey-overlay-title = "Lock Screen"; };
  };
  "Ctrl+Alt+Delete" = {
    spawn = [ "dms" "ipc" "call" "processlist" "focusOrToggle" ];
    parameters = { hotkey-overlay-title = "Task Manager"; };
  };
  "XF86AudioRaiseVolume" = {
    spawn = [ "dms" "ipc" "call" "audio" "increment" "3" ];
    parameters = { allow-when-locked = true; };
  };
  "XF86AudioLowerVolume" = {
    spawn = [ "dms" "ipc" "call" "audio" "decrement" "3" ];
    parameters = { allow-when-locked = true; };
  };
  "XF86AudioMute" = {
    spawn = [ "dms" "ipc" "call" "audio" "mute" ];
    parameters = { allow-when-locked = true; };
  };
  "XF86AudioMicMute" = {
    spawn = [ "dms" "ipc" "call" "audio" "micmute" ];
    parameters = { allow-when-locked = true; };
  };
  "XF86AudioPause" = {
    spawn = [ "dms" "ipc" "call" "mpris" "playPause" ];
    parameters = { allow-when-locked = true; };
  };
  "XF86AudioPlay" = {
    spawn = [ "dms" "ipc" "call" "mpris" "playPause" ];
    parameters = { allow-when-locked = true; };
  };
  "XF86AudioPrev" = {
    spawn = [ "dms" "ipc" "call" "mpris" "previous" ];
    parameters = { allow-when-locked = true; };
  };
  "XF86AudioNext" = {
    spawn = [ "dms" "ipc" "call" "mpris" "next" ];
    parameters = { allow-when-locked = true; };
  };
  "XF86MonBrightnessUp" = {
    spawn = [ "dms" "ipc" "call" "brightness" "increment" "5" "" ];
    parameters = { allow-when-locked = true; };
  };
  "XF86MonBrightnessDown" = {
    spawn = [ "dms" "ipc" "call" "brightness" "decrement" "5" "" ];
    parameters = { allow-when-locked = true; };
  };
}

