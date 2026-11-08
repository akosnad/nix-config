{ lib
, rustPlatform
, fetchFromGitHub
, nix-update-script
,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "glum";
  version = "0.4.1";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "jaschadub";
    repo = "glum";
    tag = "v${finalAttrs.version}";
    hash = "sha256-K0teAcbdXaK2Snnxt+eTybznsV0RxSfyifm+t8FQzM4=";
  };

  cargoHash = "sha256-R4vRRyhyQVuY58VUY0yQTk76t58QcpDFmOG1TzghCgg=";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "TUI Markdown Reader";
    homepage = "https://github.com/jaschadub/glum";
    changelog = "https://github.com/jaschadub/glum/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;
    mainProgram = "glum";
  };
})
