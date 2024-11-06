{ inputs, lib, ... }: {
  imports = [
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-pc-ssd

    ./hardware-configuration.nix
    ./disk-config.nix
    ./network.nix

    ../common/global
    ../common/optional/high-availability.nix
    ../common/optional/ephemeral-btrfs.nix
    ../common/optional/docker
    ../common/optional/docker/watchtower.nix
    ../common/optional/docker/arion.nix
    ../common/optional/builder
    ../common/optional/aarch64.nix
    ../common/optional/buildbot-worker.nix
    ../common/optional/hercules-ci-agent.nix
    ../common/optional/use-builders.nix

    ../common/users/akos

    ./buildbot-master.nix
    ./esphome.nix
    ./containers
  ];

  boot.kernelParams = [
    # disable graphics
    "nomodeset"
  ];

  virtualisation.docker = {
    storageDriver = "btrfs";
  };

  services.hercules-ci-agent.settings.concurrentTasks = 8;

  nix.distributedBuilds = lib.mkForce false;
  nix.buildMachines = lib.mkForce [ ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
