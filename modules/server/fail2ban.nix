{
  config.flake.modules.nixos.server = {
    services.fail2ban = {
      enable = true;
      ignoreIP = [ "10.0.0.0/8" "127.0.0.0/8" "::1" "100.64.0.0/16" "fd7a:115c:a1e0::/64" ];
    };
  };
}
