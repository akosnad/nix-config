{ lib, ... }:
{
  flake.modules.nixos.obelisk = { pkgs, config, ... }:
    let
      translator = pkgs.rustPlatform.buildRustPackage rec {
        pname = "owntracks-to-dawarich";
        version = "0.1.0";
        src = ./owntracks-to-dawarich;
        cargoLock = {
          lockFile = ./owntracks-to-dawarich/Cargo.lock;
        };
        doCheck = false;
        meta.mainProgram = pname;
      };
    in
    {
      systemd.services.owntracks-to-dawarich = {
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        serviceConfig = {
          Restart = "always";
          RestartSec = 5;
          LoadCredential = "user-apikey-mapping:${config.sops.secrets.dawarich-user-apikey-mapping.path}";
          PrivateTmp = true;
        };
        environment = {
          BROKER_HOST = "gaia.home.arpa";
          BROKER_PORT = "1883";
          SUBSCRIBE_TOPIC = "owntracks/+/+";
          DAWARICH_URL = "https://timeline.home.arpa";
          RUST_LOG = "info";
        };
        script = ''
          export USER_APIKEY_MAPPING_FILE="$CREDENTIALS_DIRECTORY"/user-apikey-mapping
          ${lib.getExe translator}
        '';
      };

      sops.secrets.dawarich-user-apikey-mapping = {
        sopsFile = ./secrets.yaml;
      };
    };
}
