{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "komodo";
  version = "v2.1.2";

  src = fetchFromGitHub {
    owner = "moghtech";
    repo = "komodo";
    tag = finalAttrs.version;
    hash = "sha256-Gq88ludr/l4/UqZ1Qbbdz6U/xvnilU4F4qdLY+u68Ro=";
  };

  doCheck = false;
  
  cargoHash = "sha256-H60WYnU9mmNioVZL298UEG7CLPZA4PMMZg3Bj7THaeM=";

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
