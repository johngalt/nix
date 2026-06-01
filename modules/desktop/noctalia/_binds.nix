# This utilizes the wlib.toKdl function
# https://birdeehub.github.io/nix-wrapper-modules/lib/wlib.html#function-library-wlib.toKdl
# KDL gets kind of messy with Nix...
# To have a node with just a name (like keybind acitons), need to use an empty function
{
  "Mod+Shift+S".spawn =[ "noctalia" "msg" "screenshot-region" ];
  "Mod+Space".spawn = [ "noctalia" "msg" "panel-toggle" "launcher" ];
  "Mod+V".spawn = [ "noctalia" "msg" "panel-toggle" "clipboard" ];
  "XF86AudioRaiseVolume" = _: {
    props = { allow-when-locked = true; };
    content = { spawn = [ "noctalia" "msg" "volume-up" ]; };
  };
  "XF86AudioLowerVolume" = _: {
    props = { allow-when-locked = true; };
    content = { spawn = [ "noctalia" "msg" "volume-down" ]; };
  };
  "XF86AudioMute" = _: {
    props = { allow-when-locked = true; };
    content = { spawn = [ "noctalia" "msg" "volume-mute" ]; };
  };
  "XF86AudioMicMute" = _: {
    props = { allow-when-locked = true; };
    content = { spawn = [ "noctalia" "msg" "mic-mute" ]; };
  };
  "XF86AudioPause" = _: {
    props = { allow-when-locked = true; };
    content = { spawn = [ "noctalia" "msg" "media" "toggle" ]; };
  };
  "XF86AudioPlay" = _: {
    props = { allow-when-locked = true; };
    content = { spawn = [ "noctalia" "msg" "media" "toggle" ]; };
  };
  "XF86AudioPrev" = _: {
    props = { allow-when-locked = true; };
    content = { spawn = [ "noctalia" "msg" "media" "previous" ]; };
  };
  "XF86AudioNext" = _: {
    props = { allow-when-locked = true; };
    content = { spawn = [ "noctalia" "msg" "media" "next" ]; };
  };
  "XF86MonBrightnessUp" = _: {
    props = { allow-when-locked = true; };
    content = { spawn = [ "noctalia" "msg" "brightness-up" ]; };
  };
  "XF86MonBrightnessDown" = _: {
    props = { allow-when-locked = true; };
    content = { spawn = [ "noctalia" "msg" "brightness-down" ]; };
  };
}
