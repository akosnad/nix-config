{ inputs
, outputs
, lib
, config
, pkgs
, ...
}: {
  imports = [
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-pc-ssd

    ./hardware-configuration.nix
    ./disk-config.nix
    ./network.nix

    ../common/global
    ../common/optional/ephemeral-btrfs.nix
    ../common/optional/docker.nix
    ../common/optional/libvirt.nix
    ../common/optional/builder

    ../common/users/akos

    ./libvirt
  ];

  boot.kernelParams = [
    # disable graphics
    "nomodeset"

    # try fixing rebooting hangs by disabling hardware watchdog
    "nowatchdog"
    "modprobe.blacklist=mei_wdt,iTCO_wdt"
  ];

  virtualisation.docker = {
    enableOnBoot = true;
    storageDriver = "btrfs";

    # fixes broken networking after a nixos-rebuild switch
    # because containers are restarted
    liveRestore = false;

    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = [ "--all" ];
    };
  };

  system.autoUpgrade = {
    allowReboot = true;
    operation = "boot";
    rebootWindow = {
      lower = "02:00";
      upper = "06:00";
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
