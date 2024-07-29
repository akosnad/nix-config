{
  imports = [
    ../../common/optional/docker.nix
  ];

  virtualisation.oci-containers.containers = {
    homeassistant = {
      image = "ghcr.io/home-assistant/home-assistant:stable";
      extraOptions = [
        "--privileged"
        "--network=host"
      ];
      environment = {
        TZ = "Europe/Budapest";
      };
      volumes = [
        "/var/lib/hass:/config"
      ];
    };
  };
}
