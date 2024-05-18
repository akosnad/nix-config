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
    ../common/optional/docker.nix
    ../common/optional/libvirt.nix
    ../common/optional/builder

    ../common/users/akos

    ./libvirt
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [ "nomodeset" ];

  services.upower.enable = true;

  virtualisation.docker = {
    storageDriver = "btrfs";

    # this fixes rebooting hangs
    # and broken networking after a nixos-rebuild switch
    # because containers are restarted
    liveRestore = false;
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
