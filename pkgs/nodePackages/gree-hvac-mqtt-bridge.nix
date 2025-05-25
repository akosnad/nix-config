{ pkgs }: pkgs.buildNpmPackage rec {
  pname = "gree-hvac-mqtt-bridge";
  version = "1.2.2";

  src = pkgs.fetchFromGitHub {
    owner = "aaronsb";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-YoSAbxKC7vB/7r9HcN74GgyzEPBeZLRqE3M2QW/1gJc=";
  };

  npmDepsHash = "sha256-g4i7ruGTFq/Bm1uBYvlvV8JOD2N6VZuZZmSuMuJb/50=";
  dontNpmBuild = true;

  postInstall = ''
    # remove broken symlinks
    find $out/lib/node_modules -xtype l -type l -delete
  '';

  passthru.entrypoint = "index.js";
}
