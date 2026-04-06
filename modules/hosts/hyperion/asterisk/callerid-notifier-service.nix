{ lib, ... }:
{
  config.flake.modules.nixos."hosts/hyperion" =
    { pkgs, ... }:
    let
      package = pkgs.callPackage ./_callerid-notifier { inherit pkgs; };
    in
    {
      systemd.services.asterisk-callerid-notifier = {
        wantedBy = [ "multi-user.target" ];
        wants = [ "asterisk.service" ];
        after = [
          "asterisk.service"
          "network.target"
        ];
        serviceConfig = {
          ExecStart = lib.getExe package;
          Restart = "always";
          RestartSec = "5s";
        };
        environment = {
          RUST_LOG = "info";
          MQTT_HOST = "gaia";
          ASTERISK_ENDPOINT = "http://127.0.0.1:1098/ari";
          ASTERISK_USERNAME = "asterisk";
          ASTERISK_PASSWORD = "asterisk";
          NOTIFY_TIMEOUT = "20";
        };
      };
    };
}
