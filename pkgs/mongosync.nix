{ stdenv, lib
, fetchurl
, pkgs
, autoPatchelfHook
}:

stdenv.mkDerivation rec {
  pname = "mongodb-sync";
  version = "1.7.1";

  src = fetchurl {
    url = "https://fastdl.mongodb.org/tools/mongosync/mongosync-ubuntu2004-x86_64-${version}.tgz";
    hash = "sha256-yokdyIOCkGf+BLLfUcyeVq2uubxwtoxicDg4IFnJQzo=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = with pkgs; [
    zlib
    krb5
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -m755 -D mongosync-ubuntu2004-x86_64-${version}/bin/mongosync $out/bin/mongosync
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://studio-link.com";
    description = "MongoDB Sync";
    platforms = platforms.linux;
  };
}