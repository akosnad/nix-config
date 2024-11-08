{ config, ... }:
{
  imports = [
    ./guest.nix
  ];

  systemd.network = {
    # Raspberry Pi internal WiFi adatper
    links."10-wifi0" = {
      matchConfig.PermanentMACAddress = "dc:a6:32:19:bc:7a";
      linkConfig.Name = "wifi0";
    };

    networks."30-wifi0-bind" = {
      matchConfig.Name = "wifi0";
      networkConfig.Bridge = "br-guest";
    };
  };

  services.hostapd = {
    enable = true;
    radios."wifi0" = {
      countryCode = "HU";
      wifi4.capabilities = [ ];
      networks."wifi0" = {
        ssid = "Gaia guest";
        authentication = {
          mode = "wpa2-sha256";
          wpaPasswordFile = config.sops.secrets.gaia-ap-password.path;
        };
        settings.bridge = "br-guest";
        apIsolate = true;
      };
    };
  };

  sops.secrets.gaia-ap-password = {
    sopsFile = ../../common/secrets.yaml;
  };
}
