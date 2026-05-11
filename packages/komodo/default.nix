{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "komodo";
  version = "v2.2.0";

  src = fetchFromGitHub {
    owner = "moghtech";
    repo = "komodo";
    tag = finalAttrs.version;
    hash = "sha256-Hw0JD4e/ODK19M/bZtX9foCu5c79XA8Jgv2fleltdLs=";
  };

  doCheck = false;
  
  cargoHash = "sha256-b/AgQBmS1QfP+BOCT4xL8majVKobig5M2YJhGuXMToc=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  meta = {
    description = "A tool to build and deploy software on many servers";
    homepage = "https://github.com/moghtech/komodo";
    license = lib.licenses.gpl3Only;
    mainProgram = "komodo";
  };
})
