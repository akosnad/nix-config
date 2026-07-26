{ lib
, buildPythonPackage
, setuptools
, beautifulsoup4
, certifi
, requests
, tzdata
, pycryptodome
, fetchFromGitHub
, nix-update-script
,
}:

buildPythonPackage (finalAttrs: {
  pname = "hyundai-kia-connect-api";
  version = "4.25.2";
  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "Hyundai-Kia-Connect";
    repo = "hyundai_kia_connect_api";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vnozDW1hSJ4491l0Yg0UAGmNokB40tl28DlG7a+sdQg=";
  };

  patches = [
    ./0001-compat-downgrade-packages-for-NixOS-26.05.patch
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    beautifulsoup4
    certifi
    requests
    tzdata
    pycryptodome
  ];

  pythonImportsCheck = [
    "hyundai_kia_connect_api"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "This is a Kia UVO and Hyundai Bluelink written in python. It is primary consumed by home assistant. If you are looking for a home assistant Kia / Hyundai implementation please look here: https://github.com/Hyundai-Kia-Connect/kia_uvo. Much of this base code came from reading bluelinky and contributions to the kia_uvo home assistant project";
    homepage = "https://github.com/Hyundai-Kia-Connect/hyundai_kia_connect_api";
    changelog = "https://github.com/Hyundai-Kia-Connect/hyundai_kia_connect_api/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    mainProgram = "hyundai-kia-connect-api";
  };
})
