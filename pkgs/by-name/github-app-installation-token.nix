{ lib
, buildNpmPackage
, fetchFromGitHub
, nix-update-script
,
}:

buildNpmPackage (finalAttrs: {
  pname = "github-app-installation-token";
  version = "1.2.0";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "gagoar";
    repo = "github-app-installation-token";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UKAZZK6ZsTMOfpS3cYxPjbFLghSbmCvVIvruVpnhxv0=";
  };

  npmDepsHash = "sha256-c8OtKG17uNQ8YU/6u8PO1hUmYuhB5ITdDkyQgkwFhuw=";
  npmBuildScript = "build-cli";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Npm/script and binary 📦  to get a token from a GitHub App";
    homepage = "https://github.com/gagoar/github-app-installation-token";
    changelog = "https://github.com/gagoar/github-app-installation-token/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    mainProgram = "github-app-installation-token";
    platforms = lib.platforms.all;
  };
})
