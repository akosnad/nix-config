{ stdenvNoCC, fetchFromGitHub }:
stdenvNoCC.mkDerivation rec {
  pname = "webrtc-camera";
  version = "3.6.1";

  src = fetchFromGitHub {
    owner = "AlexxIT";
    repo = "WebRTC";
    rev = "v${version}";
    hash = "sha256-/Rw95G7Ro0QvKZ7SNMIA/Q8Kr56QQqxos+t1xksuDJ0=";
  };

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r $src/custom_components/webrtc/www/* $out 

    runHook postInstall
  '';
}
