{ config, ... }:
let
  baseDomain = "fzt.one";
  stunServerPort = 3478;
in
{
  services.headscale = {
    enable = true;
    settings = {
      server_url = "https://ts.${baseDomain}";
      policy.mode = "file";
      ephemeral_node_inactivity_timeout = "5m";
      database.type = "sqlite";
      dns = {
        magic_dns = true;
        base_domain = "tailnet.${baseDomain}";
        nameservers = {
          global = [
            "1.1.1.1"
            "1.0.0.1"
            "2606:4700:4700::1111"
            "2606:4700:4700::1001"
          ];
          split = {
            "home.arpa" = [ config.devices.gaia.ip ];
          };
        };
        search_domains = [ "home.arpa" ];
      };
      derp = {
        # disable other DERP servers
        urls = [ ];
        server = {
          enabled = true;
          region_id = 999;
          region_code = "fzt";
          region_name = "ts.${baseDomain} Embedded DERP";

          # we have to leave out the host part to listen on both ipv4 and ipv6
          # reference: https://github.com/golang/go/issues/9334#issuecomment-67098831
          stun_listen_addr = ":${toString stunServerPort}";
        };
      };
    };
    policy = {
      tagOwners = {
        "tag:installer" = [ "akos" ];
        "tag:trusted" = [ "akos" ];
      };
      acls = [
        { action = "accept"; src = [ "*" ]; dst = [ "tag:installer:*" ]; }
        { action = "accept"; src = [ "tag:trusted" ]; dst = [ "*:*" ]; }
      ];
      grants = [
        { src = [ "tag:trusted" "10.0.0.0/8" ]; dst = [ "tag:trusted" "10.0.0.0/8" ]; ip = [ "*:*" ]; }
      ];
    };
  };

  networking.hosts."127.0.0.1" = [ "ts.${baseDomain}" ];
  networking.nftables.enable = true;
  networking.firewall = {
    allowedUDPPorts = [ stunServerPort ];
    checkReversePath = "loose";

    # DERP requires that all ICMP packet types are
    # allowed. reference: https://tailscale.com/kb/1118/custom-derp-servers
    allowPing = true;
    extraInputRules = ''
      ip protocol icmp accept
      ip6 nexthdr ipv6-icmp accept
    '';
    extraForwardRules = ''
      ip protocol icmp accept
      ip6 nexthdr ipv6-icmp accept
    '';
  };

  services.nginx.virtualHosts."ts.${baseDomain}" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      extraConfig = /* nginx */ ''
        proxy_pass http://${config.services.headscale.address}:${toString config.services.headscale.port};
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        proxy_set_header Host $server_name;
        proxy_redirect http:// https://;
        proxy_buffering off;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        add_header Strict-Transport-Security "max-age=15552000; includeSubDomains" always;
      '';
    };
  };

  environment.persistence."/persist".directories = [{
    directory = "/var/lib/headscale";
    mode = "750";
    inherit (config.services.headscale) user group;
  }];

  topology.networks.tailnet = {
    name = "Headscale tailnet (${config.services.headscale.settings.dns.base_domain})";
    cidrv4 = config.services.headscale.settings.prefixes.v4;
    cidrv6 = config.services.headscale.settings.prefixes.v6;
  };
}
