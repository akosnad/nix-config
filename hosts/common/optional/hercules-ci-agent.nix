{ lib, config, ... }:
{
  services.hercules-ci-agent = {
    enable = true;
    settings.concurrentTasks = lib.mkDefault 4;
  };

  sops.secrets.hci-binary-caches = {
    sopsFile = ../secrets.yaml;
    path = config.services.hercules-ci-agent.settings.binaryCachesPath;
    owner = config.systemd.services.hercules-ci-agent.serviceConfig.User;
  };
  sops.secrets.hci-join-token = {
    sopsFile = ../secrets.yaml;
    path = config.services.hercules-ci-agent.settings.clusterJoinTokenPath;
    owner = config.systemd.services.hercules-ci-agent.serviceConfig.User;
  };
}
