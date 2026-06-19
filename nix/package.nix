{
  stdenv,
  lib,
}:

stdenv.mkDerivation {
  pname = "binternet";
  version = "git";

  src = ../.;

  installPhase = ''
    mkdir $out
    cp -r * $out
  '';

  meta = {
    description = "A custom Pinterest frontend, made in PHP";
    homepage = "https://github.com/unazikx/binternet-nix";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
}
