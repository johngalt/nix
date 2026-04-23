# This utilizes the wlib.toKdl function
# https://birdeehub.github.io/nix-wrapper-modules/lib/wlib.html#function-library-wlib.toKdl
# KDL gets kind of messy with Nix...
# To have a node with just a name (like keybind acitons), need to use an empty function
{ pkgs, lib, ... }:
{
  "Mod+Shift+S".spawn-sh = "dms screenshot --cursor=off -d ~/Pictures/Screenshots";
  "Mod+Ctrl+S".spawn-sh = "dms screenshot --stdout | ${lib.getExe pkgs.satty} -f - --early-exit --save-after-copy --actions-on-enter save-to-clipboard --output-filename ~/Pictures/Screenshots/satty-$(date '+%Y%m%d-%H:%M:%S').png";
  "Mod+Space".spawn = [ "dms" "ipc" "call" "launcher" "toggle" ];
  "Mod+V".spawn = [ "dms" "ipc" "call" "clipboard" "toggle" ];
  "Mod+N".spawn = [ "dms" "ipc" "call" "notifications" "toggle" ];
  "Mod+Shift+N".spawn = [ "dms" "ipc" "call" "notepad" "toggle" ];
  "XF86AudioRaiseVolume" = _: {
    props = { allow-when-locked = true; };
    content = { spawn = [ "dms" "ipc" "call" "audio" "increment" "3" ]; };
  };
  "XF86AudioLowerVolume" = _: {
    props = { allow-when-locked = true; };
    content = { spawn = [ "dms" "ipc" "call" "audio" "decrement" "3" ]; };
  };
  "XF86AudioMute" = _: {
    props = { allow-when-locked = true; };
    content = { spawn = [ "dms" "ipc" "call" "audio" "mute" ]; };
  };
  "XF86AudioMicMute" = _: {
    props = { allow-when-locked = true; };
    content = { spawn = [ "dms" "ipc" "call" "audio" "micmute" ]; };
  };
  "XF86AudioPause" = _: {
    props = { allow-when-locked = true; };
    content = { spawn = [ "dms" "ipc" "call" "mpris" "playPause" ]; };
  };
  "XF86AudioPlay" = _: {
    props = { allow-when-locked = true; };
    content = { spawn = [ "dms" "ipc" "call" "mpris" "playPause" ]; };
  };
  "XF86AudioPrev" = _: {
    props = { allow-when-locked = true; };
    content = { spawn = [ "dms" "ipc" "call" "mpris" "previous" ]; };
  };
  "XF86AudioNext" = _: {
    props = { allow-when-locked = true; };
    content = { spawn = [ "dms" "ipc" "call" "mpris" "next" ]; };
  };
  "XF86MonBrightnessUp" = _: {
    props = { allow-when-locked = true; };
    content = { spawn = [ "dms" "ipc" "call" "brightness" "incrememnt" "5" ]; };
  };
  "XF86MonBrightnessDown" = _: {
    props = { allow-when-locked = true; };
    content = { spawn = [ "dms" "ipc" "call" "brightness" "decrement" "5" ]; };
  };
}
