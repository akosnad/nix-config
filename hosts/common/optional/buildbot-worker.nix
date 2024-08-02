{ inputs, config, ... }:
{
  imports = [
    inputs.buildbot-nix.nixosModules.buildbot-worker
  ];

  services.buildbot-nix.worker = {
    enable = true;
    name = config.networking.hostName;
    workerPasswordFile = "/run/secrets/buildbot-worker-password";
    masterUrl = ''tcp:host=zeus:port=9989'';
  };

  sops.secrets.buildbot-worker-password = {
    sopsFile = ../secrets.yaml;
    owner = config.systemd.services.buildbot-worker.serviceConfig.User;
  };
}
