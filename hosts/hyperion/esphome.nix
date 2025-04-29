{ config, ... }:
{
  services.esphome = {
    enable = true;
    address = "0.0.0.0";
  };

  services.nginx.virtualHosts."${config.networking.hostName}".locations."/esphome" = {
    extraConfig = /* nginx */ ''
      rewrite ^(/esphome)$ $1/ permanent;
      rewrite /esphome/(.*) /$1 break;
      proxy_pass http://127.0.0.1:${toString config.services.esphome.port};
      proxy_set_header Host $host;
      proxy_redirect http:// https://;
      proxy_http_version 1.1;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection $connection_upgrade;
      proxy_set_header X-Forwarded-Host $http_host;
    '';
  };

  environment.persistence."/persist".directories = [{
    directory = "/var/lib/private/esphome";
    mode = "750";
    user = "esphome";
    group = "esphome";
  }];

  sops.secrets.esphome-secrets = {
    sopsFile = ./secrets.yaml;
    path = "/etc/esphome/secrets.yaml";
    owner = "esphome";
    group = "esphome";
  };
}
