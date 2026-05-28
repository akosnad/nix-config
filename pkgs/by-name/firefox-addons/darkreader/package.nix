{ lib
, buildNpmPackage
, fetchFromGitHub
,
}:

buildNpmPackage rec {
  pname = "darkreader";
  version = "4.9.125";

  src = fetchFromGitHub {
    owner = "darkreader";
    repo = "darkreader";
    rev = "v${version}";
    hash = "sha256-CpDSKiN1291up8BxDAD1E5+wrpuCzEpL5+KQUa5JnjA=";
  };

  patches = [ ./0001-feat-remove-popup-tabs-upon-install-and-uninstall.patch ];

  npmDepsHash = "sha256-ld1hyhyssbG8cI5Kxe5oRECbkFx6hNcoSprIQUf9GAM";

  installPhase = ''
    target_dir="$out/share/mozilla/extensions/{${passthru.storeUuid}}"
    target="$target_dir/${passthru.addonId}.xpi"
    mkdir -p "$target_dir"
    cp build/release/darkreader-firefox.xpi "$target"
  '';

  passthru = {
    addonId = "addon@darkreader.org";
    storeUuid = "ec8030f7-c20a-464f-9b0e-13a3a9e97384";
  };

  meta = {
    description = "Dark Reader Chrome and Firefox extension";
    homepage = "https://github.com/darkreader/darkreader";
    changelog = "https://github.com/darkreader/darkreader/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    mainProgram = "darkreader";
    platforms = lib.platforms.all;
  };
}
