{ pkgs }: pkgs.buildHomeAssistantComponent rec {
  owner = "chomupashchuk";
  domain = "ariston";
  version = "2.0.14";

  src = pkgs.fetchFromGitHub {
    inherit owner;
    repo = "ariston-remotethermo-home-assistant-v2";
    rev = "${version}";
    hash = "sha256-k5QZlvZehfpz5/SsfnVQcbpEKGBs6f+wzPmEKvPUugM=";
  };

  propagatedBuildInputs = [ ];
}
