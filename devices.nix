{
  # servers
  gaia = {
    info = "Raspberry Pi 4B";
    ip = "10.0.0.1";
  };
  zeus = {
    info = "Core i7 2600, 16GB RAM";
    hidden = true;
    mac = "FA:49:89:96:57:D1";
    ip = "10.0.0.2";
  };

  hyperion = {
    info = "Core i7 4790S, 32GB RAM";
    mac = "74:D0:2B:90:C3:BC";
    ip = "10.0.0.3";
    extraHostnames = [ "frigate" ];
    forwardedPorts = [
      # qbittorrent
      15577

      # SIP
      { proto = "udp"; dest = 5060; }

      # plex
      { proto = "tcp"; dest = 32400; source = 20020; }
    ];
  };

  # access points
  ap-eloszoba = {
    info = "Xiaomi AC1200 Router (AP mode)";
    mac = "24:CF:24:56:CA:6E";
    ip = "10.1.0.1";
    blockInternetAccess = { ip = true; };
  };
  ap-nagyszoba = {
    info = "Xiaomi Mi Router 4 Gigabit (AP mode)";
    mac = "28:D1:27:BE:7B:3D";
    ip = "10.1.0.2";
    blockInternetAccess = { ip = true; };
  };
  ap-kert = {
    info = "Xiaomi Mi Router 4 Gigabit (AP mode)";
    mac = "3C:CD:57:73:05:22";
    ip = "10.1.0.3";
    blockInternetAccess = { ip = true; };
  };
  ap-old = {
    info = "Xiaomi Mi Router 4 (OpenWRT)";
    hidden = true;
    mac = "96:5F:26:76:7C:8C";
    ip = "10.1.0.4";
    blockInternetAccess = { ip = true; };
  };

  # desktop machines
  kratos = {
    info = "Ryzen 3600X, 32GB RAM, Radeon 7800XT";
    mac = "A8:5E:45:CD:FC:8A";
    ip = "10.2.0.1";
  };
  athena = {
    info = "Surface Laptop Go";
    mac = "64:BC:58:6D:94:F3";
    ip = "10.2.0.2";
    connectionMedium = "wifi";
  };
  Apollo = {
    info = "Surface Pro 11";
    mac = "C4:CB:76:B5:7E:8B";
    ip = "10.2.0.3";
    connectionMedium = "wifi";
  };
  Orion = {
    info = "Surface Pro 11";
    mac = "84:B1:E2:63:43:61";
    ip = "10.2.0.4";
    connectionMedium = "wifi";
  };
  Orion-lan = {
    info = "Surface Dock";
    mac = "D8:E2:DF:FD:EF:54";
    ip = "10.2.0.5";
  };

  # other machines
  Tecil = {
    info = "TCL TV";
    mac = "08:C3:B3:94:7A:53";
    ip = "10.2.1.1";
  };

  # mobile phones
  AkosRNP = {
    info = "Redmi Note 13 Pro 5G";
    mac = "A4:E2:87:E5:0E:6D";
    ip = "10.3.0.1";
    connectionMedium = "wifi";
  };
  KaziRNP = {
    info = "Redmi Note 13 Pro 5G";
    mac = "C0:16:93:E3:AE:4B";
    ip = "10.3.0.2";
    connectionMedium = "wifi";
  };
  AniRNP = {
    info = "Redmi Note 13 Pro 5G";
    mac = "22:3B:91:96:90:93";
    ip = "10.3.0.3";
    connectionMedium = "wifi";
  };
  Sylvester = {
    info = "Mi 9 SE (kiosk)";
    mac = "60:AB:67:FA:52:09";
    ip = "10.3.0.4";
    connectionMedium = "wifi";
  };
  Aether = {
    info = "Mi 9 SE (kiosk)";
    mac = "60:AB:67:FA:79:EF";
    ip = "10.3.0.5";
    connectionMedium = "wifi";
  };

  # security devices
  alarm = {
    info = "ESP32-based custom alarm system";
    mac = "02:00:00:FC:18:01";
    ip = "10.4.0.1";
    blockInternetAccess = true;
  };
  arges = {
    info = "Uniarch UHO-B1R-M2F3";
    mac = "C4:79:05:5E:B8:8C";
    ip = "10.4.0.2";
    blockInternetAccess = true;
  };

  # lights
  l-eloszoba = {
    info = "Mi LED Ceiling light (ceil5) (modded controller)";
    mac = "D8:13:2A:2E:DA:20";
    ip = "10.4.1.1";
    blockInternetAccess = true;
    connectionMedium = "wifi";
  };
  arwen = {
    info = "Yeelight Arwen 550C (ceilc)";
    mac = "B4:60:ED:0F:CB:0D";
    ip = "10.4.1.2";
    blockInternetAccess = true;
    connectionMedium = "wifi";
  };
  l-overhead = {
    info = "Athom 15W RGBCT Bulb";
    mac = "4C:EB:D6:DC:7F:4A";
    ip = "10.4.1.3";
    blockInternetAccess = true;
    connectionMedium = "wifi";
  };
  l-desk = {
    info = "Mi Desk Lamp (custom firmware)";
    mac = "7C:49:EB:D2:22:DB";
    ip = "10.4.1.4";
    blockInternetAccess = true;
    connectionMedium = "wifi";
  };
  l-desk-led = {
    info = "Tuya-based RGB LED strip (modded controller)";
    mac = "28:6D:CD:07:2A:6B";
    ip = "10.4.1.5";
    blockInternetAccess = true;
    connectionMedium = "wifi";
  };
  l-fali = {
    info = "Athom 15W RGBCT Bulb";
    mac = "D4:8C:49:0E:A0:78";
    ip = "10.4.1.6";
    blockInternetAccess = true;
    connectionMedium = "wifi";
  };
  ranarp = {
    info = "Athom 15W RGBCT Bulb";
    mac = "D4:8C:49:0E:8A:5F";
    ip = "10.4.1.7";
    blockInternetAccess = true;
    connectionMedium = "wifi";
  };
  kp105 = {
    info = "TP-Link Smart Plug (KP105)";
    mac = "28:EE:52:41:3F:98";
    ip = "10.4.1.8";
    blockInternetAccess = true;
    connectionMedium = "wifi";
  };
  l-pavilon = {
    info = "Tuya-based RGB LED strip (custom firmware)";
    mac = "D4:A6:51:91:0D:9E";
    ip = "10.4.1.9";
    blockInternetAccess = true;
    connectionMedium = "wifi";
  };

  # ESPHome
  cerberus = {
    info = "Garden gate controller";
    mac = "98:CD:AC:2E:F9:0C";
    ip = "10.4.2.1";
    blockInternetAccess = true;
    connectionMedium = "wifi";
  };
  indoor-sensor = {
    mac = "8C:AA:B5:7C:FA:80";
    ip = "10.4.2.2";
    blockInternetAccess = true;
    connectionMedium = "wifi";
  };
  outside-sensor = {
    mac = "8C:AA:B5:7A:AD:A6";
    ip = "10.4.2.3";
    blockInternetAccess = true;
    connectionMedium = "wifi";
  };
  outside-front-sensor = {
    mac = "98:CD:AC:26:10:8A";
    ip = "10.4.2.4";
    blockInternetAccess = true;
    connectionMedium = "wifi";
  };
  pavilon-sensor = {
    mac = "D8:13:2A:2E:E2:D4";
    ip = "10.4.2.6";
    blockInternetAccess = true;
    connectionMedium = "wifi";
  };

  # other IoT
  helios = {
    info = "Gree HVAC";
    mac = "F4:91:1E:F6:E3:A3";
    ip = "10.4.3.1";
    blockInternetAccess = true;
    connectionMedium = "wifi";
  };
  hades = {
    info = "Ariston heater";
    mac = "24:D7:EB:99:17:4C";
    ip = "10.4.3.2";
    connectionMedium = "wifi";
  };
  kalliope = {
    info = "Canon LBP121";
    mac = "6C:3C:7C:35:3E:2B";
    ip = "10.4.3.3";
  };
  persephone = {
    info = "Grandstream HT801 based \"smart phone\"";
    mac = "EC:74:D7:20:2C:C7";
    ip = "10.4.3.4";
    blockInternetAccess = true;
  };
  vili = {
    info = "ESP32-based custom car tracker";
    mac = "34:86:5D:5F:18:20";
    ip = "10.4.3.5";
    connectionMedium = "wifi";
  };
  airfryer = {
    info = "Mi Smart Air Fryer (3.5L)";
    mac = "58:B6:23:EC:9C:16";
    ip = "10.4.3.6";
    connectionMedium = "wifi";
  };
  prometheus = {
    info = "Anker SOLIX C300 DC";
    mac = "F4:9D:8A:6D:18:09";
    ip = "10.4.3.7";
    connectionMedium = "wifi";
  };
}
