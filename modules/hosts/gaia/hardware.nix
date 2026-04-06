{ inputs, ... }:
{
  config.flake.modules.nixos."hosts/gaia" = {
    imports = with inputs.hardware.nixosModules; [
      raspberry-pi-4
    ];

    hardware.raspberry-pi."4" = {
      gpio.enable = true;
      i2c1 = {
        enable = true;
        frequency = 100000;
      };
    };

    hardware.raspberry-pi."4".bluetooth.enable = true;
    hardware.bluetooth.enable = true;

    boot.kernelParams = [
      # tell the serial driver to use only one port,
      # without this it doesn't load.
      "8250.nr_uarts=1"
    ];
  };
}
