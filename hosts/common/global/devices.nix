{
  devices = {
    gaia = {
      ip = "10.20.0.1";
    };
    ap1 = {
      mac = "96:5F:26:76:7C:8C";
      ip = "10.20.0.3";
    };
    ap2 = {
      mac = "28:d1:27:be:7b:3d";
      ip = "10.20.0.5";
    };
    ap3 = {
      mac = "3C:CD:57:73:05:22";
      ip = "10.20.0.6";
    };
    helios = {
      mac = "F4:91:1E:F6:E3:A3";
      ip = "10.20.0.30";
    };
    kratos = {
      mac = "A8:5E:45:CD:FC:8A";
      ip = "10.20.0.96";
    };
    zeus = {
      mac = "2C:27:D7:1F:98:BD";
      ip = "10.20.0.4";
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
    arges = {
      mac = "C4:79:05:5E:B8:8C";
      ip = "10.20.0.45";
    };
    ranarp = {
      mac = "44:23:7C:CA:40:4F";
      ip = "10.20.0.231";
    };
    kalliope = {
      mac = "6C:3C:7C:35:3E:2B";
      ip = "10.20.0.88";
    };
    kp105 = {
      mac = "28:EE:52:41:3F:98";
      ip = "10.20.0.123";
    };
    persephone = {
      mac = "EC:74:D7:20:2C:C7";
      ip = "10.20.0.185";
    };
  };
}
