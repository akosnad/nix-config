{ lib, config, ... }:
{
  services.hercules-ci-agent = {
    enable = true;
    concurrentTasks = lib.mkDefault 4;
  };

  sops.secrets.hci-binary-caches = {
    sopsFile = ../secrets.yaml;
    path = "/var/lib/hercules-ci-agent/secrets/binary-caches.json";
    owner = config.systemd.services.hercules-ci-agent.serviceConfig.User;
  };
  sops.secrets.hci-join-token = {
    sopsFile = ../secrets.yaml;
    path = "/var/lib/hercules-ci-agent/secrets/cluster-join-token.key";
    owner = config.systemd.services.hercules-ci-agent.serviceConfig.User;
  };
}
