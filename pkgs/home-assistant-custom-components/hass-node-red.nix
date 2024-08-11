{ pkgs }: pkgs.buildHomeAssistantComponent rec {
  owner = "zachowj";
  domain = "nodered";
  version = "4.0.1";

  src = pkgs.fetchFromGitHub {
    owner = owner;
    repo = "hass-node-red";
    rev = "v${version}";
    hash = "sha256-ePphcSWSWhI51iNJsKryuo52ck7S5LuNREfvndIuVfs=";
  };

  propagatedBuildInputs = [ ];
}
