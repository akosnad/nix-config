{ rustPlatform
, ...
}:
rustPlatform.buildRustPackage rec {
  pname = "niri-dynamic-border-manager";
  version = "0.1.0";
  src = ./.;
  cargoLock.lockFile = ./Cargo.lock;
  doCheck = false;

  meta.mainProgram = pname;
}
