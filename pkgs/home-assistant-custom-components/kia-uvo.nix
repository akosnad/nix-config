{ lib
, buildHomeAssistantComponent
, hyundai-kia-connect-api
, fetchFromGitHub
, nix-update-script
,
}:
buildHomeAssistantComponent (finalAttrs: {
  owner = "Hyundai-Kia-Connect";
  domain = "kia_uvo";
  version = "3.8.0";

  src = fetchFromGitHub {
    inherit (finalAttrs) owner;
    repo = finalAttrs.domain;
    tag = "v${finalAttrs.version}";
    hash = "sha256-/nBthSkhtRah/R0/ANLqrGebzQhgsRy/CDgJ5FyLCok=";
  };

  dependencies = [ hyundai-kia-connect-api ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A Home Assistant HACS integration that supports Kia Connect(Uvo) and Hyundai Bluelink. The integration supports the EU, Canada and the USA";
    homepage = "https://github.com/Hyundai-Kia-Connect/kia_uvo";
    changelog = "https://github.com/Hyundai-Kia-Connect/kia_uvo/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    mainProgram = "kia-uvo";
    platforms = lib.platforms.all;
  };
})
