{ pkgs }: pkgs.buildHomeAssistantComponent rec {
  owner = "amaximus";
  domain = "bkk_stop";
  version = "2.10.1";

  src = pkgs.fetchFromGitHub {
    inherit owner;
    repo = "bkk_stop";
    rev = "${version}";
    hash = "sha256-y9xtsLPQhlBBkAGAgMulwBAFwFhQ8Cy89uOh6XjIS9g=";
  };

  propagatedBuildInputs = [ ];
}
