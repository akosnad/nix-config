{
  config.flake.devices = {
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
    kronos = {
      info = "Rigol DHO924S oscilloscope";
      mac = "00:19:AF:A0:3D:75";
      ip = "10.4.3.8";
      blockInternetAccess = true;
    };
    iris = {
      info = "BUSE BS120 LED matrix display (custom controller)";
      mac = "02:00:00:FC:18:B5";
      ip = "10.4.3.9";
      blockInternetAccess = true;
    };
    hecate = {
      info = "LG DF365FPS dishwasher";
      mac = "30:34:DB:73:0A:84";
      ip = "10.4.3.10";
      connectionMedium = "wifi";
    };
  };
}
