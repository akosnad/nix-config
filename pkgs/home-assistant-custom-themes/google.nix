{ pkgs }: pkgs.stdenvNoCC.mkDerivation rec {
  pname = "google-theme";
  version = "1.4";

  src = pkgs.fetchFromGitHub {
    owner = "JuanMTech";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-7sZp+GsSRMUYrqzCeBmw3hlTpUvHY5W0NYxZpZpH2f8=";
  };

  name = "${pname}-${version}";
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/${pname}
    cp $src/themes/*.yaml $out/${pname}/.
  '';
}
