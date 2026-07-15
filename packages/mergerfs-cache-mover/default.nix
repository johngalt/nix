# TODO: Is there a better way to write this derivation?
{
  pkgs,
  fetchFromGitHub,
  python3Packages,
  ...
}:
let
  version = "1.4.3";
  pname = "mergerfs-cache-mover";

  runEnv = pkgs.python3.buildEnv.override {
    extraLibs = with python3Packages; [ pyyaml psutil requests apprise ];
    ignoreCollisions = true;
  };

  src = fetchFromGitHub {
    owner = "monstermuffin";
    repo = pname;
    tag = "v${version}";
    hash = "sha256-ElBbyVbDw0wsjnj73P0mnEa5Uqed6gjJRYYGhqmshPQ=";
  };
in
pkgs.writeShellApplication {
  name = pname;
  runtimeInputs = [ runEnv ];
  text = ''
    python ${src}/cache-mover.py "$@"
  '';
}
