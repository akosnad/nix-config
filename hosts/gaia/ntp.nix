{
  services.chrony = {
    enable = true;
    extraFlags = [
      # no RTC on this host, always set system time to last shutdown time
      "-s"
    ];
    extraConfig = ''
      allow
    '';
  };
  services.timesyncd.enable = false;
}
