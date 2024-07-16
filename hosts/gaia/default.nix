{ inputs, ... }:
{
  imports = [
    inputs.hardware.nixosModules.raspberry-pi-4

    ./hardware-configuration.nix
    ./disk-config.nix
    ./network.nix
    ./home-assistant

    ../common/global
    ../common/optional/use-builders.nix
    ../common/optional/docker.nix
    ../common/optional/high-availability.nix

    ../common/users/akos
  ];

  system.stateVersion = "24.05";
}
