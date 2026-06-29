{
  fetchurl,
  lib,
  makeWrapper,
  stdenvNoCC,
  unzip,
}:

let
  version = "2.12.2";

  licenseFile = fetchurl {
    url = "https://raw.githubusercontent.com/WilliamVenner/gmpublisher/${version}/LICENSE";
    hash = "sha256-0b/Hp0mVCSS9XSfe5hCsiTP5a63BSndL55bphrnc06o=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "gmpublisher-darwin";
  inherit version;

  src = fetchurl {
    url = "https://github.com/WilliamVenner/gmpublisher/releases/download/${version}/gmpublisher_macOS.app.zip";
    hash = "sha256-QHMFVPee0P6b44jlCrzCxO7E5ivXkSrmT+dS0fhgckQ=";
  };

  nativeBuildInputs = [
    makeWrapper
    unzip
  ];

  dontBuild = true;
  dontConfigure = true;

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications" "$out/bin"
    cp -R gmpublisher.app "$out/Applications/"

    makeWrapper "$out/Applications/gmpublisher.app/Contents/MacOS/gmpublisher" "$out/bin/gmpublisher"

    install -Dm644 ${licenseFile} "$out/share/licenses/gmpublisher/LICENSE"

    runHook postInstall
  '';

  meta = {
    description = "Workshop Publishing Utility for Garry's Mod";
    homepage = "https://github.com/WilliamVenner/gmpublisher";
    license = lib.licenses.gpl3Only;
    mainProgram = "gmpublisher";
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
