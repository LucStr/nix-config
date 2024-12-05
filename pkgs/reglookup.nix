{stdenv, scons, talloc}:
stdenv.mkDerivation {
  pname = "reglookup";
  version = "1.0.1";
  src = fetchGit {
    url = "https://salsa.debian.org/pkg-security-team/reglookup";
    ref = "main";
    rev = "93adc9e3a30a10485d9f8c2b88e0dfad36089286";
  };

  nativeBuildInputs = [ scons ];
  buildInputs = [ talloc ];

  installPhase = ''
    PREFIX=$out scons install
  '';

  meta = {
    description = "Registry Lookup tool";
  };

}
