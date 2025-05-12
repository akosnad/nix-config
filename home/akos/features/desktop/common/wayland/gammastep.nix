{
  services.gammastep = {
    enable = true;
    enableVerboseLogging = true;
    provider = "manual";
    latitude = 47.4;
    longitude = 19.2;
    temperature = {
      day = 6600;
      night = 3000;
    };
    settings = {
      general.adjustment-method = "wayland";
    };
  };
}
