{
  services.gammastep = {
    enable = true;
    enableVerboseLogging = true;
    provider = "geoclue2";
    temperature = {
      day = 6000;
      night = 3000;
    };
    settings = {
      general.adjustment-method = "wayland";
    };
  };
}
