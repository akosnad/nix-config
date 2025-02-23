{ config, ... }:
{
  services.esphome = {
    enable = true;
    address = config.devices."${config.networking.hostName}".ip;
  };

  services.nginx.virtualHosts."${config.networking.hostName}".locations."/esphome" = {
    extraConfig = /* nginx */ ''
      rewrite /esphome/(.*) /$1 break;
      proxy_pass http://127.0.0.1:6052;
    '';
  };

  networking.firewall.allowedTCPPorts = [ 6052 ];

  environment.persistence."/persist".directories = [{
    directory = "/var/lib/private/esphome";
    mode = "750";
    user = "esphome";
    group = "esphome";
  }];
}
