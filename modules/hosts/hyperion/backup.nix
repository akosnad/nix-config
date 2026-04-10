{
  config.flake.modules.nixos."hosts/hyperion" =
    _:
    let
      withPrefix = prefix: paths: map (path: "${prefix}/${path}") paths;
    in
    {
      services.restic.backups = {
        persist.exclude = withPrefix "/persist/var/lib" [
          "private/esphome"

          "qbittorrent/qBittorrent/logs"

          "frigate/.cache"
          "frigate/exports"
          "frigate/recordings"
          "frigate/clips"
        ];
      };

      sops.secrets.restic-persist-password = {
        sopsFile = ./secrets.yaml;
      };
      sops.secrets.restic-postgres-password = {
        sopsFile = ./secrets.yaml;
      };
    };
}
