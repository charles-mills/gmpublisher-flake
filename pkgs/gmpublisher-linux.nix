{
  autoPatchelfHook,
  copyDesktopItems,
  fetchurl,
  gdk-pixbuf,
  glib-networking,
  gst_all_1,
  gtk3,
  lib,
  makeDesktopItem,
  makeWrapper,
  openssl,
  stdenv,
  unzip,
  webkitgtk_4_0,
  wrapGAppsHook3,
  xz,
}:

let
  version = "2.12.1";

  gstPlugins = [
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-libav
  ];

  icon = fetchurl {
    url = "https://raw.githubusercontent.com/WilliamVenner/gmpublisher/${version}/src-tauri/icons/128x128.png";
    hash = "sha256-Xp+2Z8pQlQE5IZcMWLU/mE9LoINu32t4h24DhhtfQmU=";
  };

  licenseFile = fetchurl {
    url = "https://raw.githubusercontent.com/WilliamVenner/gmpublisher/${version}/LICENSE";
    hash = "sha256-0b/Hp0mVCSS9XSfe5hCsiTP5a63BSndL55bphrnc06o=";
  };
in
stdenv.mkDerivation {
  pname = "gmpublisher";
  inherit version;

  src = fetchurl {
    url = "https://github.com/WilliamVenner/gmpublisher/releases/download/${version}/gmpublisher_linux64.zip";
    hash = "sha256-C1YapJwkKlg9W8XDScRlMo4aWuytb1otHhMNOFibnfo=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    makeWrapper
    unzip
    wrapGAppsHook3
  ];

  buildInputs = [
    gdk-pixbuf
    gtk3
    openssl
    stdenv.cc.cc.lib
    webkitgtk_4_0
    xz
  ];

  dontWrapGApps = true;

  desktopItems = [
    (makeDesktopItem {
      name = "gmpublisher";
      desktopName = "gmpublisher";
      comment = "Workshop Publishing Utility for Garry's Mod, written in Rust & Svelte and powered by Tauri";
      exec = "gmpublisher";
      icon = "gmpublisher";
      categories = [
        "Utility"
        "Game"
      ];
    })
  ];

  installPhase = ''
    runHook preInstall

    appdir="$out/lib/gmpublisher"
    install -Dm755 gmpublisher "$appdir/gmpublisher"
    install -Dm644 libsteam_api.so "$appdir/libsteam_api.so"

    install -Dm644 ${icon} "$out/share/icons/hicolor/128x128/apps/gmpublisher.png"
    install -Dm644 ${licenseFile} "$out/share/licenses/gmpublisher/LICENSE"

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper "$out/lib/gmpublisher/gmpublisher" "$out/bin/gmpublisher" \
      "''${gappsWrapperArgs[@]}" \
      --prefix LD_LIBRARY_PATH : "$out/lib/gmpublisher" \
      --prefix GIO_EXTRA_MODULES : "${glib-networking}/lib/gio/modules" \
      --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "${
        lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" gstPlugins
      }" \
      --set WEBKIT_DISABLE_COMPOSITING_MODE 1
  '';

  meta = {
    description = "Workshop Publishing Utility for Garry's Mod";
    homepage = "https://github.com/WilliamVenner/gmpublisher";
    license = lib.licenses.gpl3Only;
    mainProgram = "gmpublisher";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
