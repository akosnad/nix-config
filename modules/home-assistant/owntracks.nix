{
  flake.modules.nixos.home-assitant = {
    services.home-assistant = {
      extraComponents = [ "owntracks" ];
      config.owntracks = {
        max_gps_accuracy = 150;
        waypoints = false;
        mqtt_topic = "owntracks/#";
        events_only = false;
      };
    };
  };
}
