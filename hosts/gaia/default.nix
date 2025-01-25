{ inputs, lib, config, ... }:
{
  imports = [
    inputs.hardware.nixosModules.raspberry-pi-4

    ./hardware-configuration.nix
    ./network
    ./home-assistant
    ./postgresql.nix
    ./mqtt.nix
    ./backup.nix
    ./step-ca

    ../common/global
    ../common/optional/use-builders.nix
    ../common/optional/high-availability.nix
    ../common/optional/fail2ban.nix

    ../common/users/akos
  ];

  environment.persistence."/persist".enable = lib.mkForce false;

  hardware.raspberry-pi."4".bluetooth.enable = true;
  hardware.bluetooth.enable = true;
  # required by home assistant bluetooth integration
  # reference: https://www.home-assistant.io/integrations/bluetooth/#requirements-for-linux-systems
  services.dbus.implementation = "broker";

  services.nginx = {
    enable = true;
    virtualHosts.gaia = {
      forceSSL = true;
      enableACME = true;
      serverAliases = [ "gaia.${config.networking.domain}" ];
    };
  };

  system.stateVersion = "24.05";
}
