{
  services.openntpd = {
    enable = true;
    extraConfig = ''
      listen on *
    '';
  };
}
