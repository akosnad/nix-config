{ inputs, lib, ... }: {
  imports = [
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-cpu-amd-pstate
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
    ../common/optional/yubikey.nix
    ../common/optional/use-builders.nix
    ../common/optional/xwayland-fix.nix
    ../common/optional/virt-manager.nix
    ../common/optional/printing.nix
    ../common/optional/nautilus.nix

    ../common/users/akos

    ./steam.nix
    ./vivado.nix
  ];

  networking.hostName = "kratos";
  networking.networkmanager.enable = true;

  hardware.nvidia.prime.offload.enable = false;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # needed for Windows dual boot
  time.hardwareClockInLocalTime = true;

  virtualisation.docker.storageDriver = "btrfs";

  nix.distributedBuilds = lib.mkForce false;
  nix.buildMachines = lib.mkForce [ ];

  programs.nh.clean.enable = false;

  # needed to open for firewall
  programs.kdeconnect.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
