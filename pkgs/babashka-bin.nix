{ stdenv, fetchurl, unzip, autoPatchelfHook, zlib, ... }:

stdenv.mkDerivation rec {
  name = "babashka-bin";
  version = "0.3.6";

  src = fetchurl {
    url = "https://github.com/borkdude/babashka/releases/download/v${version}/babashka-${version}-linux-amd64.tar.gz";
    sha256 = "sha256-KlfiaUTzBm4lzbkMrX41bnsI84yVbgchLL6y96XCmNE=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    stdenv.cc.cc.lib
    zlib
  ];

  unpackPhase = ''
    tar -xzf $src
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
