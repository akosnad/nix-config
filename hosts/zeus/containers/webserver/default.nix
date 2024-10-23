{ lib, config, pkgs, ... }:
let
  commonServiceOptions = {
    networks = [ "internal" ];
    labels = { "com.centurylinklabs.watchtower.enable" = "true"; };
    environment = {
      TZ = "Europe/Budapest";
    };
  };

  publicVolumes = [
    "/raid/akos/Backup/webarchive/:/serve/webarchive:ro"
    "/raid/Torrents/:/serve/torrents:ro"
    "/raid/internet-public/:/serve/pub:ro"
  ];

  repo-robots = pkgs.writeText "robots.txt" ''
    User-agent: *
    Disallow: /
  '';

  deps = [
    "media-server"
    "torrent"
    "cloudflare"
  ];

  publicMountSecrets = {
    repo-htpasswd = "/etc/nginx/passwd";
    repo-htpasswd-torrents = "/etc/nginx/passwd-torrents";
  };
  lanMountSecrets = {
    zeus-crt = "/ca/zeus.crt";
    zeus-key = "/ca/zeus.key";
    repo-crt = "/ca/repo.crt";
    repo-key = "/ca/repo.key";
  };
  mkSecretVolumes = lib.mapAttrsToList (name: path: "${config.sops.secrets."${name}".path}:${path}:ro");
in
{
  virtualisation.arion.projects.webserver.settings = {
    services = {
      lan-webserver.service = lib.recursiveUpdate commonServiceOptions {
        image = "nginx";
        ports = [ "80:80" "443:443" ];
        networks = [ "internal" "torrent_internal" "media-server_internal" ];
        volumes =
          [
            "${./lan.conf}:/etc/nginx/conf.d/default.conf:ro"
            "/raid/pxe/:/srv/http/ipxe:ro"
            "/raid/Public/:/srv/http/public:ro"
            "/raid/Torrents/:/srv/http/Torrents:ro"
            "/raid/Radarr/:/srv/http/Radarr:ro"
            "/raid/Sonarr/:/srv/http/Sonarr:ro"
          ] ++ publicVolumes ++ (mkSecretVolumes lanMountSecrets);
      };

      lan-php.service = lib.recursiveUpdate commonServiceOptions {
        image = "php:fpm-alpine";
        volumes = [ ];
      };

      public-webserver.service = lib.recursiveUpdate commonServiceOptions {
        image = "nginx";
        networks = lib.mkForce [ "cloudflare_tunnel" ];
        volumes =
          [
            "${./public.conf}:/etc/nginx/conf.d/default.conf:ro"
            "${repo-robots}:/serve/robots.txt:ro"
          ] ++ publicVolumes ++ (mkSecretVolumes publicMountSecrets);
        blkio_config.weight = 900;
      };
    };

    networks = {
      internal.driver = "bridge";
      torrent_internal.external = true;
      media-server_internal.external = true;
      cloudflare_tunnel.external = true;
    };
  };

  systemd.services.arion-webserver =
    let
      deps' = map (name: "arion-${name}.service") deps;
    in
    {
      after = deps';
      wants = deps';
      requires = deps';
    };

  sops.secrets = lib.mapAttrs
    (_: _: {
      sopsFile = ../../secrets.yaml;

      # nginx is run as 101:101 inside the containers
      # reference: https://github.com/docker-library/docs/tree/master/nginx#user-and-group-id
      uid = 101;
      gid = 101;
    })
    (lanMountSecrets // publicMountSecrets);
}
