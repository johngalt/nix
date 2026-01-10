{
  pkgs,
  fetchFromGitHub,
  python3Packages,
  ...
}:
let 
  version = "1.4";
  pname = "mergerfs-cache-mover";

  runEnv = pkgs.python3.buildEnv.override {
    extraLibs = with python3Packages; [ pyyaml psutil requests apprise ];
    ignoreCollisions = true;
  };

  src = fetchFromGitHub {
    owner = "monstermuffin";
    repo = pname;
    tag = "v${version}";
    hash = "sha256-zg+Cx60y+RzUvi4GjO5Az79fgwn8l9NJXyHqAPf6IP0=";
  };
in 
pkgs.writeShellApplication {
  name = pname;
  runtimeInputs = [ runEnv ];
  text = ''
    python ${src}/cache-mover.py "$@"
  '';
}
