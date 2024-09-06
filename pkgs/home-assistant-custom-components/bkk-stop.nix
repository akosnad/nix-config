{ pkgs }: pkgs.buildHomeAssistantComponent rec {
  owner = "amaximus";
  domain = "bkk_stop";
  version = "2.9.10";

  src = pkgs.fetchFromGitHub {
    inherit owner;
    repo = "bkk_stop";
    rev = "${version}";
    hash = "sha256-R8DFohLWHEM0mhYGaLwPC/vMLLpnQ5VQwLMS0ORgGUk=";
  };

  propagatedBuildInputs = [ ];
}
