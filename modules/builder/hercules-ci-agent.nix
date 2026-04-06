{ lib, ... }:
{
  config.flake.modules.nixos.hercules-ci-agent =
    { config, ... }:
    {
      services.hercules-ci-agent = {
        enable = true;
        settings.concurrentTasks = lib.mkDefault 4;
      };

      sops.secrets.hci-binary-caches = {
        path = config.services.hercules-ci-agent.settings.binaryCachesPath;
        owner = config.systemd.services.hercules-ci-agent.serviceConfig.User;
      };
      sops.secrets.hci-join-token = {
        path = config.services.hercules-ci-agent.settings.clusterJoinTokenPath;
        owner = config.systemd.services.hercules-ci-agent.serviceConfig.User;
      };
    };
}
