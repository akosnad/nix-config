{ lib
, stdenv
, fetchFromGitHub
, nix-update-script
, scdoc
, which
, fzf
, gawk
, vdirsyncer
, bash
, util-linux
, bat
, git
,
}:

stdenv.mkDerivation (_finalAttrs: {
  pname = "fzf-vjour";
  version = "0-unstable-2026-04-04";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "blueingreen68";
    repo = "fzf-vjour";
    rev = "c9fbecb69511841196245594e9a9525852f85cef";
    hash = "sha256-hXT1BRHPPJMLbM+i9zE2dCba++/YrGy0wsEodMTQsmU=";
  };

  nativeBuildInputs = [
    scdoc
    which
  ];
  buildInputs = [
    fzf
    gawk
    vdirsyncer
    bash
    util-linux # for uuidgen
    bat
    git
  ];

  buildPhase = ''
    runHook preBuild
    make build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    BIN_DIR=$out/bin MAN_DIR=$out/share/man make install
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A fzf-based journaling and notes application with CalDav support";
    homepage = "https://github.com/blueingreen68/fzf-vjour";
    license = lib.licenses.mit;
    mainProgram = "fzf-vjour";
    platforms = lib.platforms.all;
  };
})
