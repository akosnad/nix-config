{ inputs, lib, ... }:
{
  imports = [
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-gpu-nvidia
    inputs.hardware.nixosModules.common-pc-ssd


    ./hardware-configuration.nix
    ./disk-config.nix

    ../common/global
    ../common/optional/ephemeral-btrfs.nix
    ../common/optional/secureboot.nix
    ../common/optional/nvidia.nix
    ../common/optional/high-availability.nix
    ../common/optional/docker
    ../common/optional/docker/watchtower.nix
    ../common/optional/docker/arion.nix
    ../common/optional/builder
    ../common/optional/aarch64.nix
    ../common/optional/use-builders.nix
    ../common/optional/fail2ban.nix
    ../common/optional/nix-cache-proxy.nix

    ../common/users/akos

    ./buildbot
    ./esphome.nix
    ./containers
    ./webserver.nix
    ./backup.nix
    ./frigate.nix
    ./asterisk
    ./harmonia.nix
  ];

  networking.hostName = "hyperion";
  networking.hosts = {
    # this hack fixes Radarr and Sonarr not being able to request downloads
    # issue:
    # - hyperion.home.arpa resolves to 127.0.0.2 in containers
    # - port 443 has nothing in container -> http req fails
    # TODO: find why they look for this hostname and patch it out to their internal ports
    "127.0.0.2" = lib.mkForce [ ];
  };

  hardware.nvidia.prime.offload.enable = false;

  fileSystems."/raid" = {
    device = "/dev/disk/by-label/zeusraid";
    fsType = "btrfs";
  };

  swapDevices = [{
    device = "/swap/swapfile";
    size = 32 * 1024;
  }];

  virtualisation.docker = {
    storageDriver = "btrfs";
  };

  # urbit
  networking.firewall.allowedTCPPorts = [ 4398 ];
  users.users.akos.linger = true;

  nix.distributedBuilds = lib.mkForce false;
  nix.buildMachines = lib.mkForce [ ];

  system.stateVersion = "24.11";
}
