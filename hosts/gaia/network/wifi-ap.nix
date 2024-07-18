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
    networks."30-wifi0" = {
      matchConfig.Name = "wifi0";
      networkConfig.Bridge = "br-lan";
    };
  };

  services.hostapd = {
    enable = true;
    radios."wifi0" = {
      band = "5g";
      channel = 40;
      networks."wifi0" = {
        ssid = "Gaia2";
        authentication = {
          mode = "wpa3-sae-transition";
          saePasswordsFile = "/run/secrets-for-users/gaia-ap-password";
          wpaPasswordFile = "/run/secrets-for-users/gaia-ap-password";
        };
      };
    };
  };
}
