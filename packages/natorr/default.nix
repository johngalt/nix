{
  stdenv,
  python3,
  fetchFromGitHub,
  ...
}:
let
  pythonEnv = python3.withPackages (ps: with ps; [
    requests
    pyyaml
  ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "natorr";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "BZ00001";
    repo = "scripts";
    rev = "23e2503cc99a8b17173cf8700bc88b6652ecbe2f";
    hash = "sha256-V6NvxY+HLqwQuRPffCRor0iRanU2rpbcutuU02V+jZQ=";
  };
  
  dontBuild = true;
  dontConfigure = true;
  
  buildInputs = [ pythonEnv ];

  installPhase = ''
    mkdir -p $out/bin $out/scripts
    cp -t $out/scripts -r upgradinatorr renameinatorr blocklist_cleaner asset_cleanup

    install -Dm755 $out/scripts/upgradinatorr/upgradinatorr.py $out/bin/upgradinatorr
    install -Dm755 $out/scripts/renameinatorr/renameinatorr.py $out/bin/renameinatorr
    install -Dm755 $out/scripts/blocklist_cleaner/blocklist_cleaner.py $out/bin/blocklist_cleaner
    install -Dm755 $out/scripts/asset_cleanup/asset_cleanup.py $out/bin/asset_cleanup
  '';
})
