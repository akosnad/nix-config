{ lib, config, ... }:
{
  config.flake.modules.nixos."hosts/hyperion" = {
    imports = with config.flake.modules.nixos; [
      # profiles
      base
      akos
      server
      builder
      use-builders

      # boot
      ephemeral-btrfs
      secureboot
      nvidia

      # services
      arion
      docker-watchtower
      nix-cache-proxy
      urbit
      esphome-updater
      buildbot-master
      buildbot-worker
    ] ++ [{
      home-manager.users.akos = {
        imports = with config.flake.modules.homeManager; [
          # profiles
          base
          akos

          # services
          urbit
        ];
      };
    }];

    networking.hostName = "hyperion";
    systemd.machineId = "ed9bb28513ec4f34add5bc3dfdba8e88";
    networking.hosts = {
      # this hack fixes Radarr and Sonarr not being able to request downloads
      # issue:
      # - hyperion.home.arpa resolves to 127.0.0.2 in containers
      # - port 443 has nothing in container -> http req fails
      # TODO: find why they look for this hostname and patch it out to their internal ports
      "127.0.0.2" = lib.mkForce [ ];
    };

    nix.distributedBuilds = lib.mkForce false;
    nix.buildMachines = lib.mkForce [ ];

    system.stateVersion = "24.11";
  };
}
