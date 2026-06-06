{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  zip,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "snapraid-daemon";
  version = "1.10";

  src = fetchFromGitHub {
    owner = "amadvance";
    repo = "snapraid-daemon";
    tag = "v${finalAttrs.version}";
    hash = "sha256-YBr8m8a6xJctKVLoPbsGB4zay5bY4JdGTfNY2cks9NU=";
  };

  env.VERSION = finalAttrs.version;

  doCheck = true;

  nativeBuildInputs = [
    autoreconfHook
    zip
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A lightweight daemon for SnapRAID featuring a REST API, job scheduler, and web interface";
    homepage = "https://github.com/amadvance/snapraid-daemon";
    changelog = "https://github.com/amadvance/snapraid-daemon/releases/tag/${finalAttrs.src.tag}";
    license = with lib.licenses; [
      bsd2
      gpl3Only
      mit
    ];
    maintainers = with lib.maintainers; [ ];
    mainProgram = "snapraid-daemon";
    platforms = lib.platforms.all;
  };
})
