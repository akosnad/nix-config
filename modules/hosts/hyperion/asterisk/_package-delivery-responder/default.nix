{ pkgs ? import <nixpkgs> { }, ... }:
let
  cargoToml = builtins.fromTOML (builtins.readFile ./Cargo.toml);
  inherit (cargoToml.package) name version;
in
pkgs.rustPlatform.buildRustPackage {
  pname = name;
  inherit version;
  src = ./.;
  cargoLock.lockFile = ./Cargo.lock;
  doCheck = false;
  meta.mainProgram = name;

  nativeBuildInputs = with pkgs; [
    pkg-config
  ];
  buildInputs = with pkgs; [
    openssl
  ];
}
