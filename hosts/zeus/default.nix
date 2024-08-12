{ inputs
, ...
}: {
  imports = [
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-pc-ssd

    ./hardware-configuration.nix
    ./disk-config.nix
    ./network.nix
    ./esphome.nix

    ../common/global
    ../common/optional/high-availability.nix
    ../common/optional/ephemeral-btrfs.nix
    ../common/optional/docker
    ../common/optional/libvirt.nix
    ../common/optional/builder
    ../common/optional/aarch64.nix
    ../common/optional/buildbot-worker.nix
    ../common/optional/hercules-ci-agent.nix

    ../common/users/akos

    ./libvirt
    ./buildbot-master.nix
  ];

  boot.kernelParams = [
    # disable graphics
    "nomodeset"

    # try fixing rebooting hangs by disabling hardware watchdog
    "nowatchdog"
    "modprobe.blacklist=mei_wdt,iTCO_wdt"
  ];

  virtualisation.docker = {
    storageDriver = "btrfs";
  };

  services.hercules-ci-agent.settings.concurrentTasks = 8;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
