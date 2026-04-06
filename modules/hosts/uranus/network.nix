{ lib, ... }:
{
  config.flake.modules.nixos."hosts/uranus" =
    { config, ... }:
    {
      services.openssh.openFirewall = lib.mkForce false;

      security.acme.defaults = lib.mkForce {
        server = "https://acme-v02.api.letsencrypt.org/directory";
        validMinDays = 30;
        email = "contact@fzt.one";
      };

      services.cloudflared = {
        enable = true;
        certificateFile = config.sops.secrets.cloudflared-cert.path;
        tunnels.uranus = {
          default = "http_status:404";
          credentialsFile = config.sops.secrets.cloudflared-creds.path;
        };
      };

      sops.secrets.cloudflared-cert = {
        sopsFile = ./secrets.yaml;
      };
      sops.secrets.cloudflared-creds = {
        sopsFile = ./secrets.yaml;
      };

    };
}
