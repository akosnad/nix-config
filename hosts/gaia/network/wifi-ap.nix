{
  sops.secrets.gaia-ap-password = {
    sopsFile = ../../common/secrets.yaml;
    neededForUsers = true;
  };

  systemd.network = {
    # Raspberry Pi internal WiFi adatper
    links."10-wifi0" = {
      matchConfig.PermanentMACAddress = "dc:a6:32:aa:3c:d2";
      linkConfig.Name = "wifi0";
    };
  };

  services.hostapd = {
    enable = true;
    radios."wifi0" = {
      networks."wifi0" = {
        ssid = "Gaia2";
        authentication = {
          mode = "wpa2-sha256";
          wpaPasswordFile = "/run/secrets-for-users/gaia-ap-password";
        };
        settings.bridge = "br-lan";
      };
    };
  };
}
