{
	lib,
	fetchFromGitHub,
	stdenvNoCC,
	...
}:

stdenvNoCC.mkDerivation (self: {
  name = "gruvbox-material.yazi";

  src = fetchFromGitHub {
    owner = "matt-dong-123";
    repo = "gruvbox-material.yazi";
    rev = "6c3649144592ceb073abc1c14a9f270655484db0";
    hash = "sha256-N3tmcqGLFa6ERQ8yvPyPw2XCWUs4KtQP6/WktccsaoE=";
  };

  dontConfigure = true;
  dontBuild = true;
  preferLocalBuild = true;

  installPhase = ''
    runHook preInstall
    cp -r . $out
    runHook postInstall
  '';

  meta = with lib; {
    description = "Gruvbox-material flavor for yazi";
    homepage = "https://github.com/matt-dong-123/gruvbox-material.yazi";
    platforms = platforms.all;
  };
})
