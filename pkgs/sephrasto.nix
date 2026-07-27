# Sephrasto — DSA character generator (PySide6/Qt app).
#
# This packages the APP directly and ignores the multi-linux installer, which
# cannot work on NixOS (see notes at the bottom).
#
# Place at: pkgs/sephrasto.nix
# Build:    nix-build -E 'with import <nixpkgs> {}; callPackage ./pkgs/sephrasto.nix {}'
{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
  qt6,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
}:

let
  pythonEnv = python3.withPackages (ps: [
    ps.lxml # lxml~=6.0.2
    ps.pyside6 # PySide6~=6.9.1  <- see RISK note below
    ps.pyyaml # pyyaml~=6.0.3
    ps.restrictedpython # RestrictedPython~=8.1
  ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "sephrasto";
  version = "5.2.0";

  src = fetchFromGitHub {
    owner = "Aeolitus";
    repo = "Sephrasto";
    rev = "v${finalAttrs.version}"; # verify the actual tag name on the releases page
    # Placeholder: build once, Nix prints the correct hash, paste it here.
    hash = lib.fakeHash;
  };

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtwayland # you run Hyprland — without this Qt falls back to XWayland
    qt6.qtwebengine # DatenbankEditor imports QtWebEngineWidgets
  ];

  # We wrap manually so we can merge Qt's wrapper args with --chdir.
  dontWrapQtApps = true;

  # No setup.py / pyproject.toml upstream — it is a plain source tree.
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/sephrasto
    cp -r src/Sephrasto/. $out/share/sephrasto/

    install -Dm644 src/Sephrasto/icon_large.png \
      $out/share/icons/hicolor/256x256/apps/sephrasto.png

    mkdir -p $out/bin
    makeWrapper ${pythonEnv}/bin/python $out/bin/sephrasto \
      --add-flags $out/share/sephrasto/Sephrasto.py \
      --chdir $out/share/sephrasto \
      "''${qtWrapperArgs[@]}"

    runHook postInstall
  '';

  # --chdir is REQUIRED, not cosmetic: the app resolves its bundled reference
  # database with os.getcwd() + "/Data/datenbank.xml" (DatenbankEditor.py).
  # Launched from anywhere else it starts and then fails to find its data.
  #
  # This is safe against the read-only store because user data does NOT live in
  # the app directory — PathHelper.py puts settings in $XDG_CONFIG_HOME/Sephrasto
  # and characters in ~/sephrasto (or ~/.sephrasto). Both are writable.

  desktopItems = [
    (makeDesktopItem {
      name = "sephrasto";
      exec = "sephrasto";
      icon = "sephrasto";
      desktopName = "Sephrasto";
      comment = "Charaktergenerator für Das Schwarze Auge";
      categories = [ "Game" ];
      terminal = false;
    })
  ];

  meta = {
    description = "Character generator for the German TTRPG Das Schwarze Auge";
    homepage = "https://github.com/Aeolitus/Sephrasto";
    license = lib.licenses.mit; # CONFIRM against upstream LICENSE before upstreaming
    platforms = lib.platforms.linux;
    mainProgram = "sephrasto";
  };
})
# ---------------------------------------------------------------------------
# RISK, in the order you will hit it:
#
# 1. `hash = lib.fakeHash` fails the first build on purpose. Nix prints the real
#    hash; paste it in. Same for `rev` if the tag is not literally "v5.2.0".
#
# 2. ps.pyside6 must have been built with QtWebEngine. If you get
#    `ModuleNotFoundError: No module named 'PySide6.QtWebEngineWidgets'`,
#    that is the blocker — see the FHS fallback in my message.
#
# 3. Upstream recommends Python 3.11; this uses nixpkgs' default python3.
#    The 3.11 pin exists because of uv wheel availability, not a language
#    feature, so a newer interpreter will most likely be fine. If not:
#    python311.withPackages — but then pyside6 may need rebuilding from source.
# ---------------------------------------------------------------------------
