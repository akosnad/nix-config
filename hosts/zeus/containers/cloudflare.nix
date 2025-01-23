{ config, ... }:
{
  virtualisation.arion.projects.cloudflare.settings = {
    services = {
      tunnel.service = {
        image = "cloudflare/cloudflared:latest";
        restart = "unless-stopped";
        networks = [ "tunnel" ];
        labels = { "com.centurylinklabs.watchtower.enable" = "true"; };
        env_file = [ config.sops.secrets.cloudflared-env.path ];
        command = "tunnel --no-autoupdate run";
      };
    };

    networks.tunnel.driver = "bridge";
  };

  sops.secrets.cloudflared-env = {
    sopsFile = ../secrets.yaml;
    neededForUsers = true;
  };
}
