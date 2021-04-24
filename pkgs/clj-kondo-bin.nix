{ stdenv, fetchurl, unzip, autoPatchelfHook, zlib, ... }:

stdenv.mkDerivation rec {
  name = "clj-kondo-bin";
  version = "2020.07.29";

  src = fetchurl {
    url = "https://github.com/borkdude/clj-kondo/releases/download/v${version}/clj-kondo-${version}-linux-amd64.zip";
    sha256 = "1wsw3aqpp7k4mhzhskdr6rd26b4ngjqhyhb8nf5s4z2j6ix3xfqf";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    stdenv.cc.cc.lib
    unzip
    zlib
  ];

  unpackPhase = ''
    unzip $src
  '';

  installPhase = ''
    install -m755 -D clj-kondo $out/bin/clj-kondo
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/borkdude/clj-kondo;
    description = "A linter for Clojure code that sparks joy.";
    platforms = platforms.linux;
  };
}
