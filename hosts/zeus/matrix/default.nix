{ config, ... }:
{
  imports = [
    ./bridges.nix
  ];

  services.matrix-synapse = {
    enable = true;
    settings = {
      server_name = "m.fzt.one";
      public_baseurl = "https://m.fzt.one";
      registration_shared_secret_path = config.sops.secrets.matrix-registration-shared-secret.path;
      default_identity_server = "matrix.org";
      trusted_third_party_id_servers = [
        "martrix.org"
        "vector.im"
      ];
      allow_public_rooms_over_federation = true;
      app_service_config_files = [ config.sops.secrets.matrix-doublepuppet-config.path ];
    };
    extraConfigFiles = [ config.sops.secrets.matrix-secret-config.path ];
    extras = [
      "systemd"
      "postgres"
      "url-preview"
      "user-search"
      "oidc"
    ];
  };

  sops.secrets.matrix-registration-shared-secret = {
    sopsFile = ../secrets.yaml;
    owner = "matrix-synapse";
  };
  sops.secrets.matrix-secret-config = {
    sopsFile = ../secrets.yaml;
    owner = "matrix-synapse";
  };
  sops.secrets.matrix-doublepuppet-config = {
    sopsFile = ../secrets.yaml;
    owner = "matrix-synapse";
  };

  services.postgresql = {
    ensureUsers = [{
      name = "matrix-synapse";
      ensureDBOwnership = true;
    }];
    ensureDatabases = [ "matrix-synapse" ];
  };

  services.nginx.virtualHosts."m.fzt.one" = {
    listen = [{ addr = "0.0.0.0"; port = 9986; ssl = false; }];
    locations = {
      "~ ^(/_matrix|/_synapse)".extraConfig = /* nginx */ ''
        # note: do not add a path (even a single /) after the port in `proxy_pass`,
        # otherwise nginx will canonicalise the URI and cause signature verification
        # errors.
        proxy_pass http://127.0.0.1:8008;
        # proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header X-Forwarded-For $http_x_forwarded_for;
        # proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Proto $http_x_forwarded_proto;
        # proxy_set_header Host $host:$server_port;
        proxy_set_header Host $host;

        # Nginx by default only allows file uploads up to 1M in size
        # Increase client_max_body_size to match max_upload_size defined in homeserver.yaml
        client_max_body_size 50M;

        # Synapse responses may be chunked, which is an HTTP/1.1 feature.
        proxy_http_version 1.1;
      '';
      "/".extraConfig = /* nginx */ ''
        return 302 "https://matrix.to/#/#public:m.fzt.one";
      '';
      "/.well-known/matrix/client".extraConfig = /* nginx */ ''
        return 200 '{"m.homeserver": {"base_url": "https://m.fzt.one"}}';
        default_type application/json;
        add_header Access-Control-Allow-Origin *;
      '';
      "/.well-known/matrix/server".extraConfig = /* nginx */ ''
        return 200 '{"m.server": "m.fzt.one:443"}';
        default_type application/json;
        add_header Access-Control-Allow-Origin *;
      '';
    };
  };

  networking.firewall.allowedTCPPorts = [ 9986 ];

  environment.persistence."/persist".directories = [ config.services.matrix-synapse.dataDir ];
}
