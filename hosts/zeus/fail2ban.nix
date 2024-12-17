{
  services.fail2ban = {
    enable = true;
    ignoreIP = [ "10.20.0.0/24" "127.0.0.0/8" "::1" ];
  };
}
