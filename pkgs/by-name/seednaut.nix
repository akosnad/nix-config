{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, protobuf
, sqlite
, zstd
, nix-update-script
,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "seednaut";
  version = "0.1.1";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "Baltram";
    repo = "seednaut";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wyMOZQPJPSqLl4tzC5NELoe81aJZSOurifi62v1+jcQ=";
  };

  cargoHash = "sha256-1GZ7ZoiGKEQGN2AQFcz/YXpcqg3iYLRSzl2GfTmGk8g=";

  nativeBuildInputs = [
    pkg-config
    protobuf
  ];

  buildInputs = [
    sqlite
    zstd
  ];

  env = {
    LIBSQLITE3_SYS_USE_PKG_CONFIG = true;
    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Inspect, verify and extract files from Seedvault backups";
    homepage = "https://github.com/Baltram/seednaut";
    changelog = "https://github.com/Baltram/seednaut/releases/tag/${finalAttrs.src.tag}";
    license = with lib.licenses; [
      asl20
      mit
    ];
    mainProgram = "seednaut";
  };
})
