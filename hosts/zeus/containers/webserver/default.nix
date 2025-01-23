{ lib, config, pkgs, ... }:
let
  commonServiceOptions = {
    restart = "unless-stopped";
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
    "cloudflare"
  ];

  publicMountSecrets = {
    repo-htpasswd = "/etc/nginx/passwd";
    repo-htpasswd-torrents = "/etc/nginx/passwd-torrents";
  };
  mkSecretVolumes = lib.mapAttrsToList (name: path: "${config.sops.secrets."${name}".path}:${path}:ro");
in
{
  virtualisation.arion.projects.webserver.settings = {
    services = {
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
    publicMountSecrets;
}
