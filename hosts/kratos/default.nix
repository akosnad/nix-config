{ inputs, ... }: {
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
    ../common/optional/quietboot.nix
    ../common/optional/pipewire.nix
    ../common/optional/greetd.nix
    ../common/optional/docker
    ../common/optional/envfs.nix
    ../common/optional/builder
    ../common/optional/aarch64.nix
    # ../common/optional/buildbot-worker.nix
    ../common/optional/hercules-ci-agent.nix
    ../common/optional/yubikey.nix

    ../common/users/akos

    ./steam.nix
  ];

  networking.hostName = "kratos";
  networking.networkmanager.enable = true;

  hardware.opengl.enable = true;
  hardware.nvidia.prime.offload.enable = false;

  # needed for Windows dual boot
  time.hardwareClockInLocalTime = true;

  services.hercules-ci-agent.settings.concurrentTasks = 12;

  # TODO: make yubikey related stuff generic
  virtualisation.docker.storageDriver = "btrfs";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
