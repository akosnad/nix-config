{
  config.flake.devices = {
    ap-eloszoba = {
      info = "Xiaomi AC1200 Router (AP mode)";
      mac = "24:CF:24:56:CA:6E";
      ip = "10.1.0.1";
      blockInternetAccess.ip = true;
    };
    ap-nagyszoba = {
      info = "Xiaomi Mi Router 4 Gigabit (AP mode)";
      mac = "28:D1:27:BE:7B:3D";
      ip = "10.1.0.2";
      blockInternetAccess.ip = true;
    };
    ap-kert = {
      info = "Xiaomi Mi Router 4 Gigabit (AP mode)";
      mac = "3C:CD:57:73:05:22";
      ip = "10.1.0.3";
      blockInternetAccess.ip = true;
    };
    ap-old = {
      info = "Xiaomi Mi Router 4 (OpenWRT)";
      hidden = true;
      mac = "96:5F:26:76:7C:8C";
      ip = "10.1.0.4";
      blockInternetAccess.ip = true;
    };
  };
}
