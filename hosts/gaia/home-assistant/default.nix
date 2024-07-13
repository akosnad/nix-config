{
  services.home-assistant = {
    enable = true;
    config = {
      homeassistant = {
        name = "Gaia";
        latitude = "!secret latitude";
        longitude = "!secret longitude";
        elevation = "!secret elevation";
        unit_system = "metric";
        time_zone = "Europe/Budapest";
      };
      frontend = {
        themes = "!include_dir_merge_named themes";
      };
      http = { };
    };
  };
}
