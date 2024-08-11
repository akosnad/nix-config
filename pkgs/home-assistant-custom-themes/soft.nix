{ pkgs }: pkgs.stdenvNoCC.mkDerivation rec {
  pname = "lovelace-soft-theme";
  version = "54bc8a1";

  src = pkgs.fetchFromGitHub {
    owner = "KTibow";
    repo = pname;
    rev = "54bc8a1";
    sha256 = "sha256-jOn9yWXHCWgegTgMqXc77YNEL3Br74aRgfPcUIc+lAM=";
  };

  name = "${pname}-${version}";
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/${pname}
    cp $src/themes/*.yaml $out/${pname}/.
  '';
}
