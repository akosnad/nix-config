{
  virtualisation.oci-containers.containers.watchtower = {
    autoStart = true;
    image = "containrrr/watchtower";
    extraOptions = [
      "--label=com.centurylinklabs.watchtower.enable=true"
    ];
    volumes = [
      "/var/run/docker.sock:/var/run/docker.sock"
      "/etc/localtime:/etc/localtime:ro"
    ];
    environment = {
      WATCHTOWER_SCHEDULE = "0 30 4 * * *";
      WATCHTOWER_CLEANUP = "1";
      WATCHTOWER_LABEL_ENABLE = "1";
    };
  };
}
