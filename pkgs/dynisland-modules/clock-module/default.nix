{ pkgs } @ args: let
  mainpkg = import ../../dynisland args;
in
pkgs.rustPlatform.buildRustPackage rec {
  pname = "dynisland_clock_module";
  version = "0.1.3";

  inherit (mainpkg) src nativeBuildInputs buildInputs;
  cargoSha256 = "sha256-hoH3FJFLoSNdZSU2Ax1tQdJopFTkk5ECfdaP+HmE9nc=";
  cargoDepsName = mainpkg.pname;

  buildNoDefaultFeatures = true;
  buildFeatures = [ ];
  cargoBuildFlags = [ "--package ${pname}" ];
}
