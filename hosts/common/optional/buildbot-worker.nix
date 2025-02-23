{ inputs, config, ... }:
{
  imports = [
    inputs.buildbot-nix.nixosModules.buildbot-worker
  ];

  services.buildbot-nix.worker = {
    enable = true;
    name = config.networking.hostName;
    workerPasswordFile = "/run/secrets/buildbot-worker-password";
    masterUrl = ''tcp:host=hyperion:port=9989'';
  };

  sops.secrets.buildbot-worker-password = {
    sopsFile = ../secrets.yaml;
    owner = config.systemd.services.buildbot-worker.serviceConfig.User;
  };

  environment.persistence."/persist".directories = [{
    directory = "/var/lib/buildbot-worker";
    mode = "700";
    user = config.systemd.services.buildbot-worker.serviceConfig.User;
    group = config.systemd.services.buildbot-worker.serviceConfig.Group;
  }];
}
