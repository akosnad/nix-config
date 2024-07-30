{ inputs, lib, ... }:
{
  imports = [
    inputs.hardware.nixosModules.raspberry-pi-4

    ./hardware-configuration.nix
    ./network
    ./home-assistant

    ../common/global
    ../common/optional/use-builders.nix
    ../common/optional/high-availability.nix

    ../common/users/akos
  ];

  environment.persistence."/persist".enable = lib.mkForce false;

  system.stateVersion = "24.05";
}
