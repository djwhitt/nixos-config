{ stdenv, fetchurl, unzip, autoPatchelfHook, zlib, ... }:

stdenv.mkDerivation rec {
  name = "babashka-bin";
  version = "0.1.3";

  src = fetchurl {
    url = "https://github.com/borkdude/babashka/releases/download/v${version}/babashka-${version}-linux-amd64.zip";
    sha256 = "0nldq063a1sfk0qnkd37dpw8jq43p4divn4j4qiif6dy1qz9xdcq";
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
    install -m755 -D bb $out/bin/bb
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/borkdude/babashka;
    description = "A Clojure babushka for the grey areas of Bash.";
    platforms = platforms.linux;
  };
}
