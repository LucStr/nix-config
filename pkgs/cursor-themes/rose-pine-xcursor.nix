{ lib, stdenv, fetchurl }:
stdenv.mkDerivation (finalAttrs: {
  pname = "rose-pine-xcursor";
  version = "1.1.0";
  src = fetchurl {
    url = "https://github.com/rose-pine/cursor/releases/download/v1.1.0/BreezeX-RosePine-Linux.tar.xz";
    sha256 = "sha256-szDVnOjg5GAgn2OKl853K3jZ5rVsz2PIpQ6dlBKJoa8=";
  };

  installPhase = ''
    runHook preInstall

    tar xvf $src

    mv BreezeX-RosePine-Linux rose-pine

    mkdir -p $out/share/icons/
    cp -R . $out/share/icons/
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "Rose Pine X Cursor";
    downloadPage = "https://github.com/rose-pine/cursor/releases";
    homepage = "https://rosepinetheme.com/";
    license = licenses.gpl3;
    maintainers = with maintainers; [ LucStr ];
  };
})
