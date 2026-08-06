{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "komodo";
  version = "v2.3.1";

  src = fetchFromGitHub {
    owner = "moghtech";
    repo = "komodo";
    tag = finalAttrs.version;
    hash = "sha256-nEST1Mp/WJJ+GtsC9cX10w3thywe3dHNrQV5iLPXMIQ=";
  };

  doCheck = false;
  
  cargoHash = "sha256-krFHWiHgdBL2jIr0YsBrNG4+NaaoaSVf6q65jWiQGsg=";

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
