# Separate package for noHL script testing
{
  stdenv,
  python3,
  ...
}:
let
  pythonEnv = python3.withPackages (ps: with ps; [
    requests
    pyyaml
  ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "nohl";
  version = "unstable";

  src = fetchGit {
    url = "https://gist.github.com/f8a31d594a51bea1fb4def271eee7072.git";
    rev = "3939994292a2728fe3e2813f92f6795d85c23ce5";
  };
  
  dontBuild = true;
  dontConfigure = true;
  
  buildInputs = [ pythonEnv ];

  installPhase = ''
    mkdir -p $out/bin $out/scripts
    cp -t $out/scripts noHL.py

    install -Dm755 $out/scripts/noHL.py $out/bin/noHL
  '';
})
