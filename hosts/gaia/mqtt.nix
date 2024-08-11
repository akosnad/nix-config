{
  services.mosquitto = {
    enable = true;
    listeners = [
      {
        port = 1883;
        omitPasswordAuth = true;
        acl = [ "topic readwrite #" ];
        settings = {
          protocol = "mqtt";
          allow_anonymous = true;
        };
      }
    ];
  };
}
