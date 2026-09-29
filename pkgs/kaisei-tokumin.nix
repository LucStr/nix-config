{
  lib,
  stdenvNoCC,
  fetchurl,
}:
# Kaisei Tokumin, a Japanese mincho face (display font of the ukiyo-e desktop
# theme). Fetched file by file: pkgs.google-fonts downloads the whole
# google/fonts repository to install a single family.
let
  rev = "5174b3333331c966c38f4355d50b03ca1c1df2f9";
  font = weight: hash:
    fetchurl {
      url = "https://raw.githubusercontent.com/google/fonts/${rev}/ofl/kaiseitokumin/KaiseiTokumin-${weight}.ttf";
      inherit hash;
    };
in
  stdenvNoCC.mkDerivation {
    pname = "kaisei-tokumin";
    version = "0-unstable-2026-03-13";

    srcs = [
      (font "Regular" "sha256-P72+xTk2mu0Rux+gzdodGeokbnlRBzVzg9+lYYSKQn0=")
      (font "Bold" "sha256-RUD2tcMnJKzJxLp3aSGVB43kOk7nYtQ2450y+o0ac8k=")
    ];

    dontUnpack = true;

    installPhase = ''
      runHook preInstall
      for f in $srcs; do
        install -Dm444 "$f" "$out/share/fonts/truetype/$(stripHash "$f")"
      done
      runHook postInstall
    '';

    meta = {
      description = "Kaisei Tokumin, a Japanese mincho typeface";
      homepage = "https://fonts.google.com/specimen/Kaisei+Tokumin";
      license = lib.licenses.ofl;
      platforms = lib.platforms.all;
    };
  }
