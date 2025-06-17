let
  httpPort = 11798;
  domain = "miniflux.akosnad.dev";
in
{
  services.miniflux = {
    enable = true;
    config = {
      CREATE_ADMIN = 0;
      WEBAUTHN = 1;
      BASE_URL = "https://${domain}";
      LISTEN_ADDR = "localhost:${toString httpPort}";
    };
  };

  services.cloudflared.tunnels.uranus.ingress = {
    ${domain} = {
      service = "http://localhost:${toString httpPort}";
    };
  };
}
