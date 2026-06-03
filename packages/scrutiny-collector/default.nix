# Using forked version of scrutiny from https://github.com/Starosdev/scrutiny
{
  buildGoModule,
  fetchFromGitHub,
  makeWrapper,
  smartmontools,
  zfs,
  lib,
}:
let
  version = "1.62.2";
in
buildGoModule rec {
  inherit version;
  pname = "scrutiny-collector";

  src = fetchFromGitHub {
    owner = "Starosdev";
    repo = "scrutiny";
    tag = "v${version}";
    hash = "sha256-A2vlZMB4CeCXAOl28x97jC5ziJo30LDZQHDlpITpRsQ=";
  };

  subPackages = [
    "collector/cmd/collector-metrics"
    "collector/cmd/collector-zfs"
  ];

  vendorHash = "sha256-szldZnK87MEOxZgRWeJMIlPNHMq41+aEZ41h2olRjrQ=";

  nativeBuildInputs = [ makeWrapper ];

  env.CGO_ENABLED = 0;

  ldflags = [ "-extldflags=-static" ];

  tags = [ "static" ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp $GOPATH/bin/collector-metrics $out/bin/scrutiny-collector-metrics
    cp $GOPATH/bin/collector-zfs $out/bin/scrutiny-collector-zfs
    wrapProgram $out/bin/scrutiny-collector-metrics \
      --prefix PATH : ${lib.makeBinPath [ smartmontools ]}
    wrapProgram $out/bin/scrutiny-collector-zfs \
      --prefix PATH : ${lib.makeBinPath [ zfs ]}
    runHook postInstall
  '';

  meta = {
    description = "Hard disk metrics collector for Scrutiny";
    homepage = "https://github.com/AnalogJ/scrutiny";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "scrutiny-collector-metrics";
  };
}
