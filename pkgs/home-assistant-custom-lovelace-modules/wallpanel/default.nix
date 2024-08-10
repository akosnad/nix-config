# TODO: minify the js file
{ pkgs }: pkgs.stdenvNoCC.mkDerivation rec {
  pname = "wallpanel";
  version = "4.25.5";

  src = builtins.fetchurl {
    url = "https://github.com/j-a-n/lovelace-wallpanel/releases/download/v${version}/${pname}.js";
    sha256 = "sha256:0mab1kg5brqshwj4w1d4i3p5w3svlnhvd8kjlk6n68smjf6q6wym";
  };

  name = "${pname}-${version}";
  dontUnpack = true;
  installPhase = ''
    mkdir $out
    cp $src "$out/${pname}.js"
  '';
}
