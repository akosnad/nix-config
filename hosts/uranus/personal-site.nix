{
  services.cloudflared.tunnels.uranus.ingress = {
    "akosnad.dev" = {
      service = "http://localhost:3000";
    };
  };
}
