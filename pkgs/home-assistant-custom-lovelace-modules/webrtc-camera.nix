{ pkgs, ... }: pkgs.stdenvNoCC.mkDerivation rec {
  pname = "webrtc-camera";
  version = "3.6.0";

  src = pkgs.fetchFromGitHub {
    owner = "AlexxIT";
    repo = "WebRTC";
    rev = "v${version}";
    hash = "sha256-hw5wei+tovTarzYm92UuDq6YOHLSsbDXEA/SHUW+zrE=";
  };

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r $src/custom_components/webrtc/www/* $out 

    runHook postInstall
  '';
}
