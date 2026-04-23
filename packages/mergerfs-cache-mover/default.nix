# TODO: Is there a better way to write this derivation?
{
  pkgs,
  fetchFromGitHub,
  python3Packages,
  ...
}:
let
  version = "1.4.2";
  pname = "mergerfs-cache-mover";

  runEnv = pkgs.python3.buildEnv.override {
    extraLibs = with python3Packages; [ pyyaml psutil requests apprise ];
    ignoreCollisions = true;
  };

  src = fetchFromGitHub {
    owner = "monstermuffin";
    repo = pname;
    tag = "v${version}";
    hash = "sha256-uwFM8qaHOp46irWeZjfRGfFxhKjVbmKvpkgA4c85Meo=";
  };
in
pkgs.writeShellApplication {
  name = pname;
  runtimeInputs = [ runEnv ];
  text = ''
    python ${src}/cache-mover.py "$@"
  '';
}
