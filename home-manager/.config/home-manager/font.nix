{ stdenv, fetchzip }:

stdenv.mkDerivation rec {
  name = "hack-font";
  src = fetchzip {
    url = "https://github.com/source-foundry/Hack/releases/download/v3.003/Hack-v3.003-ttf.zip";
    sha256 = "sha256-SxF4kYp9aL/9L9EUniquFadzWt/+PcvhUQOIOvCrFRM=";
  };
  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    cp -r $src/* $out/share/fonts/truetype/
  '';
}
