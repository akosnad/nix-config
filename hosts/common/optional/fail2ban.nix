{
  services.fail2ban = {
    enable = true;
    ignoreIP = [ "10.0.0.0/8" "127.0.0.0/8" "::1" ];
  };
}
