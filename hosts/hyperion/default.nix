{ inputs, ... }:
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

    ../common/users/akos
  ];

  networking.hostName = "hyperion";

  hardware.nvidia.prime.offload.enable = false;

  system.stateVersion = "24.11";
}
