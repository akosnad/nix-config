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

    networks."50-wifi0-ap0" = {
      matchConfig.Name = "wifi0-ap0";
      networkConfig.Bridge = "br-lan";
    };
  };

  networking.wlanInterfaces = {
    "wifi0-ap0" = { device = "wifi0"; mac = "00:00:00:fc:18:01"; };
  };

  services.hostapd = {
    enable = true;
    radios."wifi0-ap0" = {
      band = "5g";
      channel = 40;
      networks."wifi0-ap0" = {
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
