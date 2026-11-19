{
  lib,
  rustPlatform,
  fetchFromGitHub,
  fetchNpmDeps,
  cargo-tauri,
  nodejs,
  npmHooks,
  patchelf,
  pkg-config,
  wrapGAppsHook3,
  glib-networking,
  openssl,
  webkitgtk_4_1,
  xz,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "gmpublisher";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "WilliamVenner";
    repo = "gmpublisher";
    tag = finalAttrs.version;
    hash = "sha256-KC/1zQC6ebNFMxF8T77OHVl2g/l1HH8Z+EB4eHJkZwE=";
  };

  cargoRoot = "src-tauri";
  buildAndTestSubdir = finalAttrs.cargoRoot;
  cargoHash = "sha256-oT4NTWh0ZwwbWZHgHWup6NLla0epetouH7psZar1s4I=";

  npmDeps = fetchNpmDeps {
    name = "${finalAttrs.pname}-${finalAttrs.version}-npm-deps";
    inherit (finalAttrs) src;
    hash = "sha256-9kBJoZbDOIYJq6yfPT+LWMcUHT92sqR/1ZG6IJ7Livk=";
  };

  postPatch = ''
    substituteInPlace src-tauri/build.rs \
      --replace-fail 'println!("cargo:rustc-link-arg=-Wl,-rpath,.");' ""

    substituteInPlace src-tauri/tauri.conf.json \
      --replace-fail '"node src-tauri/copySharedLibs.js && npm run build"' '"npm run build"'
  '';

  env.STEAM_SDK_LOCATION = "${finalAttrs.src}/src-tauri/lib/steam_api";

  nativeBuildInputs = [
    cargo-tauri.hook
    nodejs
    npmHooks.npmConfigHook
    patchelf
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    glib-networking
    openssl
    webkitgtk_4_1
    xz
  ];

  postInstall = ''
    install -Dm755 -t $out/lib/gmpublisher \
      src-tauri/lib/steam_api/redistributable_bin/linux64/libsteam_api.so
    patchelf --add-rpath $out/lib/gmpublisher $out/bin/gmpublisher
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Workshop publishing utility for Garry's Mod";
    homepage = "https://github.com/WilliamVenner/gmpublisher";
    changelog = "https://github.com/WilliamVenner/gmpublisher/releases/tag/${finalAttrs.version}";
    license = with lib.licenses; [
      gpl3Only
      valveSDK
    ];
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryNativeCode
    ];
    maintainers = [ ];
    mainProgram = "gmpublisher";
    platforms = [ "x86_64-linux" ];
  };
})
