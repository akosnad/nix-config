{ pkgs, variant }:
let
  first = builtins.substring 0 1 variant;
  rest = builtins.substring 1 (builtins.stringLength variant) variant;
  variantCapitalized = (pkgs.lib.toUpper first) + rest;
in
pkgs.stdenvNoCC.mkDerivation {
  name = "quintom-${variant}-hyprcursor";

  src = pkgs.fetchFromGitLab {
    owner = "Burning_Cube";
    repo = "quintom-cursor-theme";
    rev = "d23e57333e816033cf20481bdb47bb1245ed5d4d";
    hash = "sha256-Sec2DSnWYal6wzYzP9W+DDuTKHsFHWdRYyMzliMU5bU=";
  };

  nativeBuildInputs = with pkgs; [ hyprcursor xcur2png ];

  unpackPhase = ''
    mkdir -p source
    cp -r "$src/Quintom_${variantCapitalized} Cursors/Quintom_${variantCapitalized}"/* ./source/.
  '';

  buildPhase = ''
    hyprcursor-util -x ./source
    cat << EOF > extracted_source/manifest.hl
    name = Quintom ${variantCapitalized}
    description = A cursor theme designed to look decent.
    version = 0.1
    cursors_directory = hyprcursors
    EOF

    hyprcursor-util -c ./extracted_source
  '';

  installPhase = ''
    target="$out/usr/share/icons/Quintom ${variantCapitalized}"
    mkdir -p "$target"
    cp -r "theme_Quintom ${variantCapitalized}"/* "$target"
  '';
}
