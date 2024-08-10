{ pkgs }: pkgs.buildNpmPackage rec {
  pname = "plotly-graph-card";
  version = "3.3.4";

  src = pkgs.fetchFromGitHub {
    owner = "dbuezas";
    repo = "lovelace-plotly-graph-card";
    rev = "v${version}";
    hash = "sha256-nQePl1pIAerBJRcAbqHQm56xLuA5qzbyz+8Ofa5kMc0=";
  };

  npmInstallFlags = [ "--omit=dev" ];
  npmDepsHash = "sha256-dXazjhMzBjPzO10aESlS5EuN6UdCY97KO/8+zwzYc1s=";

  patches = [ ./fix-deps.patch ];
  makeCacheWritable = true;

  nativeBuildInputs = with pkgs; [ esbuild ];
  installPhase = ''
    runHook preInstall

    mkdir $out
    cp dist/plotly-graph-card.js $out

    runHook postInstall
  '';

  passthru.entrypoint = "plotly-graph-card.js";
}
