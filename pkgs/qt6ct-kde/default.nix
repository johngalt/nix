{
  cmake,
  fetchFromGitLab,
  lib,
  qtbase,
  qtsvg,
  qttools,
  qtwayland,
  stdenv,
  wrapQtAppsHook,
  pkgs,
  fetchpatch2
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qt6ct-kde";
  version = "0.11";

  src = fetchFromGitLab {
    domain = "www.opencode.net";
    owner = "trialuser";
    repo = "qt6ct";
    tag = finalAttrs.version;
    hash = "sha256-aQmqLpM0vogMsYaDS9OeKVI3N53uY4NBC4FF10hK8Uw=";
  };

  nativeBuildInputs = [
    cmake
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    qtsvg
    qtwayland
    pkgs.kdePackages.qqc2-desktop-style # Taken from AUR version
  ];

  cmakeFlags = [
    (lib.cmakeFeature "PLUGINDIR" "${placeholder "out"}/${qtbase.qtPluginPrefix}")
  ];

  # Patch set from AUR
  patches = [
    (fetchpatch2 {
      url = "https://gist.githubusercontent.com/johngalt/51ae85bdc88266a45e11817aec3914e7/raw/1975f2da9d4af602a6691dc9421eeeaff05d95a5/qt6ct-shenanigans.patch";
      hash = "sha256-2/MRzIp1K2LqITcNvRRaR5WUQ11MmaCg+wJpR7eLu2M=";
    })
  ];

  meta = {
    description = "Qt6 Configuration Tool";
    homepage = "https://www.opencode.net/trialuser/qt6ct";
    platforms = lib.platforms.linux;
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [
      Flakebi
      Scrumplex
    ];
    mainProgram = "qt6ct";
  };
})
