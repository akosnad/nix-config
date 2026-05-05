{
  config.flake.modules.nixos."hosts/uranus" = { config, pkgs, ... }: {

    services.shadowsocks = {
      enable = true;
      passwordFile = config.sops.secrets.shadowsocks-password.path;
      plugin = "${pkgs.shadowsocks-v2ray-plugin}/bin/v2ray-plugin";
      pluginOpts = "server";
    };

    services.cloudflared = {
      enable = true;
      tunnels.uranus.ingress = {
        "s.fzt.one" = "http://127.0.0.1";
      };
    };

    services.nginx.virtualHosts."s.fzt.one" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.shadowsocks.port}";
        proxyWebsockets = true;
      };
    };

    sops.secrets.shadowsocks-password = { };
  };

  config.flake.modules.nixos."hosts/work-laptop" = { config, pkgs, ... }: {
    systemd.services.ss-ssh-tun = {
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [
        shadowsocks-libev
        shadowsocks-v2ray-plugin
      ];
      script = ''ss-tunnel -c ${config.sops.secrets.ss-tun-config.path} -v -L 127.0.0.1:22'';
    };

    sops.secrets.ss-tun-config = {
      sopsFile = ../hosts/work-laptop/secrets.yaml;
    };
  };
}
