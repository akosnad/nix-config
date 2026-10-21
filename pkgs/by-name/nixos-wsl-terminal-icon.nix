{ stdenvNoCC
, nixos-icons
, imagemagick
}:
stdenvNoCC.mkDerivation {
  name = "nixos-wsl-terminal-icon";

  src = "${nixos-icons}";

  nativeBuildInputs = [
    imagemagick
  ];

  buildPhase = ''
    mkdir -p $out
    convert -background transparent -transparent white \
      -define 'icon:auto-resize=16,24,32,64,128' \
      ${nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg \
      "$out"/nixos.ico
  '';
}
