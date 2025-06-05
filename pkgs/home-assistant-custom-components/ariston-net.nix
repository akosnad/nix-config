{ pkgs }: pkgs.buildHomeAssistantComponent rec {
  owner = "chomupashchuk";
  domain = "ariston";
  version = "2.0.16";

  src = pkgs.fetchFromGitHub {
    inherit owner;
    repo = "ariston-remotethermo-home-assistant-v2";
    rev = "${version}";
    hash = "sha256-4WTJnbxjBtZSTZbskNSnxxFSpJtx6V6F/MVkueK1Vdw=";
  };

  propagatedBuildInputs = [ ];
}
