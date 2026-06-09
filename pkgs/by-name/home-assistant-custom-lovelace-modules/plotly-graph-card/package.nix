{ buildNpmPackage
, fetchFromGitHub
, esbuild
,
}:
buildNpmPackage rec {
  pname = "plotly-graph-card";
  version = "3.3.4";

  src = fetchFromGitHub {
    owner = "dbuezas";
    repo = "lovelace-plotly-graph-card";
    rev = "v${version}";
    hash = "sha256-nQePl1pIAerBJRcAbqHQm56xLuA5qzbyz+8Ofa5kMc0=";
  };

  npmInstallFlags = [ "--omit=dev" ];
  npmDepsHash = "sha256-CriXlW08/Z+Lmjzel521nriplZsiwlopzSuNYkC4IZo=";

  patches = [ ./0001-fix-deps-use-patched-regression-logarithmic-package.patch ];
  makeCacheWritable = true;

  nativeBuildInputs = [ esbuild ];
  installPhase = ''
    runHook preInstall

    mkdir $out
    cp dist/plotly-graph-card.js $out

    runHook postInstall
  '';

  passthru.entrypoint = "plotly-graph-card.js";
}
