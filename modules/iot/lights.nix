{
  config.flake.devices = {
    arwen = {
      info = "Yeelight Arwen 550C (ceilc)";
      mac = "B4:60:ED:0F:CB:0D";
      ip = "10.4.1.2";
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
  };
}
