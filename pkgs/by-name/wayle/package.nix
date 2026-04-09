{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, gtk4
, gtk4-layer-shell
, systemd
, libxkbcommon
, fftw
, pipewire
, libclang
, clang
, libpulseaudio
}:

rustPlatform.buildRustPackage rec {
  pname = "wayle";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "wayle-rs";
    repo = "wayle";
    rev = "v${version}";
    hash = "sha256-iZddhPdskoyyAYT3J92S5cRRKkkR8KyqIyBBPE+Lg18=";
  };

  LIBCLANG_PATH = "${libclang.lib}/lib";

  nativeBuildInputs = [
    pkg-config
    clang
  ];

  buildInputs = [
    gtk4
    gtk4-layer-shell
    systemd # for udev
    libxkbcommon
    fftw
    pipewire
    libclang
    libpulseaudio
  ];

  cargoHash = "sha256-bOc4BpzxqZBIwPVlJQr1Blo+0+8UyyTUAiGz2Ao8f+s=";

  meta = {
    description = "Wayland Elements -  A compositor agnostic shell with extensive customization";
    homepage = "https://github.com/wayle-rs/wayle";
    license = lib.licenses.mit;
    mainProgram = "wayle";
  };
}
