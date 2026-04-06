{ buildHomeAssistantComponent, fetchFromGitHub }:
buildHomeAssistantComponent rec {
  owner = "AlexxIT";
  domain = "webrtc";
  version = "3.6.0";

  src = fetchFromGitHub {
    inherit owner;
    repo = "WebRTC";
    rev = "v${version}";
    hash = "sha256-hw5wei+tovTarzYm92UuDq6YOHLSsbDXEA/SHUW+zrE=";
  };

  propagatedBuildInputs = [ ];
}
