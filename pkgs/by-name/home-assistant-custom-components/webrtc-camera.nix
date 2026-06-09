{ buildHomeAssistantComponent, fetchFromGitHub }:
buildHomeAssistantComponent rec {
  owner = "AlexxIT";
  domain = "webrtc";
  version = "3.6.1";

  src = fetchFromGitHub {
    inherit owner;
    repo = "WebRTC";
    rev = "v${version}";
    hash = "sha256-/Rw95G7Ro0QvKZ7SNMIA/Q8Kr56QQqxos+t1xksuDJ0=";
  };

  propagatedBuildInputs = [ ];
}
