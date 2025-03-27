{
  devices = {
    # servers
    gaia = {
      ip = "10.0.0.1";
    };
    zeus = {
      mac = "FA:49:89:96:57:D1";
      ip = "10.0.0.2";
    };
    hyperion = {
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
      mac = "24:CF:24:56:CA:6E";
      ip = "10.1.0.1";
      blockInternetAccess = { ip = true; };
    };
    ap-nagyszoba = {
      mac = "28:D1:27:BE:7B:3D";
      ip = "10.1.0.2";
      blockInternetAccess = { ip = true; };
    };
    ap-kert = {
      mac = "3C:CD:57:73:05:22";
      ip = "10.1.0.3";
      blockInternetAccess = { ip = true; };
    };
    ap-old = {
      mac = "96:5F:26:76:7C:8C";
      ip = "10.1.0.4";
      blockInternetAccess = { ip = true; };
    };

    # desktop machines
    kratos = {
      mac = "A8:5E:45:CD:FC:8A";
      ip = "10.2.0.1";
    };
    athena = {
      mac = "64:BC:58:6D:94:F3";
      ip = "10.2.0.2";
    };
    Apollo = {
      mac = "C4:CB:76:B5:7E:8B";
      ip = "10.2.0.3";
    };
    Orion = {
      mac = "84:B1:E2:63:43:61";
      ip = "10.2.0.4";
    };
    Orion-lan = {
      mac = "D8:E2:DF:FD:EF:54";
      ip = "10.2.0.5";
    };

    # other machines
    Tecil = {
      mac = "08:C3:B3:94:7A:53";
      ip = "10.2.1.1";
    };

    # mobile phones
    AkosRNP = {
      mac = "A4:E2:87:E5:0E:6D";
      ip = "10.3.0.1";
    };
    KaziRNP = {
      mac = "C0:16:93:E3:AE:4B";
      ip = "10.3.0.2";
    };
    AniRNP = {
      mac = "22:3B:91:96:90:93";
      ip = "10.3.0.3";
    };
    Sylvester = {
      mac = "60:AB:67:FA:52:09";
      ip = "10.3.0.4";
    };

    # security devices
    alarm = {
      mac = "02:00:00:FC:18:01";
      ip = "10.4.0.1";
      blockInternetAccess = true;
    };
    arges = {
      mac = "C4:79:05:5E:B8:8C";
      ip = "10.4.0.2";
      blockInternetAccess = true;
    };

    # lights
    l-eloszoba = {
      mac = "5C:E5:0C:89:2F:21";
      ip = "10.4.1.1";
      blockInternetAccess = true;
    };
    arwen = {
      mac = "B4:60:ED:0F:CB:0D";
      ip = "10.4.1.2";
      blockInternetAccess = true;
    };
    l-overhead = {
      mac = "04:CF:8C:7C:CF:E3";
      ip = "10.4.1.3";
      blockInternetAccess = true;
    };
    l-desk = {
      mac = "7C:49:EB:D2:22:DB";
      ip = "10.4.1.4";
      blockInternetAccess = true;
    };
    l-desk-led = {
      mac = "28:6D:CD:07:2A:6B";
      ip = "10.4.1.5";
      blockInternetAccess = true;
    };
    l-fali = {
      mac = "7C:C2:94:81:90:2B";
      ip = "10.4.1.6";
      blockInternetAccess = true;
    };
    ranarp = {
      mac = "44:23:7C:CA:40:4F";
      ip = "10.4.1.7";
      blockInternetAccess = true;
    };
    kp105 = {
      mac = "28:EE:52:41:3F:98";
      ip = "10.4.1.8";
      blockInternetAccess = true;
    };
    l-pavilon = {
      mac = "D4:A6:51:91:0D:9E";
      ip = "10.4.1.9";
      blockInternetAccess = true;
    };

    # ESPHome
    cerberus = {
      mac = "98:CD:AC:2E:F9:0C";
      ip = "10.4.2.1";
      blockInternetAccess = true;
    };
    indoor_sensor = {
      mac = "8C:AA:B5:7C:FA:80";
      ip = "10.4.2.2";
      blockInternetAccess = true;
    };
    outside_sensor = {
      mac = "8C:AA:B5:7A:AD:A6";
      ip = "10.4.2.3";
      blockInternetAccess = true;
    };
    outside-front-sensor = {
      mac = "98:CD:AC:26:10:8A";
      ip = "10.4.2.4";
      blockInternetAccess = true;
    };
    ha-ble-proxy = {
      mac = "D8:13:2A:2E:DA:20";
      ip = "10.4.2.5";
      blockInternetAccess = true;
    };

    # other IoT
    helios = {
      mac = "F4:91:1E:F6:E3:A3";
      ip = "10.4.3.1";
      blockInternetAccess = true;
    };
    hades = {
      mac = "24:D7:EB:99:17:4C";
      ip = "10.4.3.2";
    };
    kalliope = {
      mac = "6C:3C:7C:35:3E:2B";
      ip = "10.4.3.3";
    };
    persephone = {
      mac = "EC:74:D7:20:2C:C7";
      ip = "10.4.3.4";
      blockInternetAccess = true;
    };
    vili = {
      mac = "34:86:5D:5F:18:20";
      ip = "10.4.3.5";
    };
    airfryer = {
      mac = "58:B6:23:EC:9C:16";
      ip = "10.4.3.6";
    };
    prometheus = {
      mac = "F4:9D:8A:6D:18:09";
      ip = "10.4.3.7";
    };
  };
}
