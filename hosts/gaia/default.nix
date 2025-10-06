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
    ./ntp.nix

    ../common/global
    ../common/optional/use-builders.nix
    ../common/optional/high-availability.nix
    ../common/optional/fail2ban.nix

    ../common/users/akos
  ];

  hardware.raspberry-pi."4" = {
    gpio.enable = true;
    i2c1 = {
      enable = true;
      frequency = 100000;
    };
  };
  boot.kernelParams = [
    # tell the serial driver to use only one port,
    # without this it doesn't load.
    "8250.nr_uarts=1"
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
