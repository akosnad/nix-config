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
        "/run/secrets/home-assistant-secrets:/config/secrets.yaml:ro"
      ];
    };
  };

  sops.secrets.home-assistant-secrets = {
    owner = "root";
    sopsFile = ./secrets.yaml;
  };
}
