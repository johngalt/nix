{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
  ...
}:

stdenvNoCC.mkDerivation (self: {
  name = "eza-themes";

  src = fetchFromGitHub {
    owner = "eza-community";
    repo = "eza-themes";
    rev = "c03051f67e84110fbae91ab7cbc377b3460f035c";
    hash = "sha256-EwLxBSromsE2ZiiUs5/aI9aigbVFxSeLlZV+U/cd2K4=";
    sparseCheckout = [ "themes" ];
  };

  dontConfigure = true;
  dontBuild = true;
  preferLocalBuild = true;

  sourceRoot = "${self.src.name}/themes";
  installPhase = ''
    runHook preInstall
    install -Dt $out/share/eza-themes *.yml
    runHook postInstall
  '';

  meta = with lib; {
    description = "Collection of themes for eza";
    homepage = "https://github.com/eza-community/eza-themes";
    platforms = platforms.all;
  };
})
