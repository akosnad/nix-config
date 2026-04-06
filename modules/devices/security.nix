{
  config.flake.devices = {
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
    brontes = {
      info = "Uniview UHO-B1R-M2F3";
      mac = "88:26:3F:72:6B:4F";
      ip = "10.4.0.3";
      blockInternetAccess = true;
    };
  };
}
