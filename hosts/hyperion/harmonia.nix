{ config, ... }:
{
  services.harmonia = {
    enable = true;
    signKeyPaths = [ config.sops.secrets.harmonia-key.path ];
    settings = {
      bind = "[::]:5959";

      # cache.nixos.org is 40
      # *.cachix.org are 41
      # lower is preferred
      priority = 50;

      workers = 4;
      max_connection_rate = 256;
    };
  };
  nix.settings.allowed-users = [ "harmonia" ];

  networking.firewall.allowedTCPPorts = [ 5959 ];

  sops.secrets.harmonia-key = {
    sopsFile = ./secrets.yaml;
  };

  # LAN proxy of publc cache
  services.nginx.virtualHosts."nix.fzt.one" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:5959";
      recommendedProxySettings = true;
    };
  };
}
