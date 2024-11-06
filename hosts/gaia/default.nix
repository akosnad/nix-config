{ inputs, lib, ... }:
{
  imports = [
    inputs.hardware.nixosModules.raspberry-pi-4

    ./hardware-configuration.nix
    ./network
    ./home-assistant
    ./postgresql.nix
    ./mqtt.nix
    ./backup.nix

    ../common/global
    ../common/optional/use-builders.nix
    ../common/optional/high-availability.nix

    ../common/users/akos
  ];

  environment.persistence."/persist".enable = lib.mkForce false;

  # if binary caches are unavailable, don't try to build sources locally
  nix.settings.fallback = false;

  hardware.raspberry-pi."4".bluetooth.enable = true;
  hardware.bluetooth.enable = true;
  # required by home assistant bluetooth integration
  # reference: https://www.home-assistant.io/integrations/bluetooth/#requirements-for-linux-systems
  services.dbus.implementation = "broker";

  system.stateVersion = "24.05";
}
